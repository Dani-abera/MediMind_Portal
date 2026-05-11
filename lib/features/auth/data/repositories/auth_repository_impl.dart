import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/network/user_context.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/auth_tokens_model.dart';
import '../../domain/entities/admin_user.dart';
import '../../domain/entities/auth_tokens.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;
  final NetworkInfo _network;
  final UserContext _ctx;

  const AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required AuthLocalDataSource local,
    required NetworkInfo network,
    required UserContext ctx,
  })  : _remote = remote,
        _local = local,
        _network = network,
        _ctx = ctx;

  @override
  Future<Either<Failure, void>> doctorRequestOtp(String badgeNumber) =>
      _guard(() => _remote.doctorRequestOtp(badgeNumber));

  @override
  Future<Either<Failure, ({User user, AuthTokens tokens})>> doctorVerifyOtp({
    required String badgeNumber,
    required String otpCode,
  }) =>
      _guardResult(() async {
        final result = await _remote.doctorVerifyOtp(
          badgeNumber: badgeNumber,
          otpCode: otpCode,
        );
        await _persist(result.user, result.tokens);
        return (user: result.user, tokens: result.tokens as AuthTokens);
      });

  @override
  Future<
      Either<Failure,
          ({User user, AuthTokens tokens, bool requires2fa})>> adminLogin({
    required String email,
    required String password,
  }) =>
      _guardResult(() async {
        final result =
            await _remote.adminLogin(email: email, password: password);
        if (!result.requires2fa) {
          await _persist(result.user, result.tokens);
        }
        return (
          user: result.user,
          tokens: result.tokens as AuthTokens,
          requires2fa: result.requires2fa,
        );
      });

  @override
  Future<Either<Failure, ({User user, AuthTokens tokens})>> adminVerifyOtp({
    required String email,
    required String otpCode,
  }) =>
      _guardResult(() async {
        final result =
            await _remote.adminVerifyOtp(email: email, otpCode: otpCode);
        await _persist(result.user, result.tokens);
        return (user: result.user, tokens: result.tokens as AuthTokens);
      });

  @override
  Future<
      Either<Failure,
          ({User user, AuthTokens tokens, bool requires2fa})>> superAdminLogin({
    required String email,
    required String password,
  }) =>
      _guardResult(() async {
        final result =
            await _remote.superAdminLogin(email: email, password: password);
        if (!result.requires2fa) {
          await _persist(result.user, result.tokens);
        }
        return (
          user: result.user,
          tokens: result.tokens as AuthTokens,
          requires2fa: result.requires2fa,
        );
      });

  @override
  Future<Either<Failure, ({User user, AuthTokens tokens})>>
      superAdminVerify2fa({
    required String email,
    required String totpCode,
  }) =>
          _guardResult(() async {
            final result = await _remote.superAdminVerify2fa(
              email: email,
              totpCode: totpCode,
            );
            await _persist(result.user, result.tokens);
            return (user: result.user, tokens: result.tokens as AuthTokens);
          });

  @override
  Future<Either<Failure, AuthTokens>> refreshToken(
          String refreshToken) =>
      _guardResult(() => _remote.refreshToken(refreshToken));

  @override
  Future<Either<Failure, void>> logout() => _guard(() async {
        final refresh = await _local
            .getCachedTokens()
            .then((t) => t?.refreshToken ?? '');
        await _remote.logout(refresh);
        await _local.clearAuth();
        _ctx.clear();
      });

  @override
  Future<Either<Failure, void>> adminRegister({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  }) =>
      _guard(() => _remote.adminRegister(
            fullName: fullName,
            email: email,
            phoneNumber: phoneNumber,
            password: password,
          ));

  @override
  Future<Either<Failure, void>> requestPasswordReset(String email) =>
      _guard(() => _remote.requestPasswordReset(email));

  @override
  Future<Either<Failure, void>> resetPassword({
    required String token,
    required String newPassword,
  }) =>
      _guard(
          () => _remote.resetPassword(token: token, newPassword: newPassword));

  @override
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) =>
      _guard(() => _remote.changePassword(
          currentPassword: currentPassword, newPassword: newPassword));

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      final user = await _local.getCachedUser();
      if (user == null) return const Left(CacheFailure('No cached user'));

      final tokens = await _local.getCachedTokens();
      if (tokens == null) return const Left(CacheFailure('No cached tokens'));

      _ctx.userId = user.id;
      _ctx.userType = switch (user.role) {
        UserRole.doctor => UserType.doctor,
        UserRole.admin => UserType.admin,
        UserRole.superAdmin => UserType.superAdmin,
      };
      if (user is AdminUser) {
        _ctx.centerId = user.centerId;
        _ctx.centerStatus = user.centerStatus;
      }

      if (tokens.expiresAt.isBefore(DateTime.now())) {
        try {
          final newTokens = await _remote.refreshToken(tokens.refreshToken);
          await _local.cacheTokens(newTokens);
          _ctx.accessToken = newTokens.accessToken;
          _ctx.refreshToken = newTokens.refreshToken;
        } on AppException {
          await _local.clearAuth();
          _ctx.clear();
          return const Left(UnauthorizedFailure('Session expired'));
        } catch (_) {
          _ctx.accessToken = tokens.accessToken;
          _ctx.refreshToken = tokens.refreshToken;
        }
      } else {
        _ctx.accessToken = tokens.accessToken;
        _ctx.refreshToken = tokens.refreshToken;
      }

      return Right(user);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  Future<void> _persist(User user, AuthTokensModel tokens) async {
    await _local.cacheTokens(tokens);
    await _local.cacheUser(user);
    _ctx.accessToken = tokens.accessToken;
    _ctx.refreshToken = tokens.refreshToken;
    _ctx.userId = user.id;
    _ctx.userType = switch (user.role) {
      UserRole.doctor => UserType.doctor,
      UserRole.admin => UserType.admin,
      UserRole.superAdmin => UserType.superAdmin,
    };
    if (user is AdminUser) {
      _ctx.centerId = user.centerId;
      _ctx.centerStatus = user.centerStatus;
    }
  }

  Future<Either<Failure, void>> _guard(Future<void> Function() fn) async {
    if (!await _network.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      await fn();
      return const Right(null);
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on ForbiddenException catch (e) {
      return Left(ForbiddenFailure(e.message));
    } on BadRequestException catch (e) {
      return Left(BadRequestFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on ConflictException catch (e) {
      return Left(ConflictFailure(e.message));
    } on NetworkTimeoutException catch (e) {
      return Left(TimeoutFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AppException catch (e) {
      return Left(UnknownFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  Future<Either<Failure, T>> _guardResult<T>(
      Future<T> Function() fn) async {
    if (!await _network.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      return Right(await fn());
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on ForbiddenException catch (e) {
      return Left(ForbiddenFailure(e.message));
    } on BadRequestException catch (e) {
      return Left(BadRequestFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on ConflictException catch (e) {
      return Left(ConflictFailure(e.message));
    } on NetworkTimeoutException catch (e) {
      return Left(TimeoutFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AppException catch (e) {
      return Left(UnknownFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}

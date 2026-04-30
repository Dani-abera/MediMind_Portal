import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:medimind_portal/core/error/exceptions.dart';
import 'package:medimind_portal/core/error/failures.dart';
import 'package:medimind_portal/core/network/network_info.dart';
import 'package:medimind_portal/core/network/user_context.dart';
// UserContext is a singleton — use it directly in tests
import 'package:medimind_portal/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:medimind_portal/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:medimind_portal/features/auth/data/models/auth_tokens_model.dart';
import 'package:medimind_portal/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:medimind_portal/features/auth/domain/entities/doctor_user.dart';
import 'package:medimind_portal/features/auth/domain/entities/user.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

class _FakeUser extends Fake implements User {}

class _FakeAuthTokensModel extends Fake implements AuthTokensModel {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeUser());
    registerFallbackValue(_FakeAuthTokensModel());
  });
  late MockAuthRemoteDataSource remote;
  late MockAuthLocalDataSource local;
  late MockNetworkInfo networkInfo;
  late AuthRepositoryImpl repository;

  final tUser = DoctorUser(
    id: 'doc-1',
    fullName: 'Dr. Test',
    email: 'test@medimind.et',
    badgeNumber: 'DR-001',
    specialization: 'General',
  );
  final tTokens = AuthTokensModel(
    accessToken: 'access',
    refreshToken: 'refresh',
    expiresAt: DateTime.now().add(const Duration(hours: 1)),
  );

  setUp(() {
    remote = MockAuthRemoteDataSource();
    local = MockAuthLocalDataSource();
    networkInfo = MockNetworkInfo();
    repository = AuthRepositoryImpl(
      remote: remote,
      local: local,
      network: networkInfo,
      ctx: UserContext(),
    );

    when(() => networkInfo.isConnected).thenAnswer((_) async => true);
    when(() => local.cacheUser(any())).thenAnswer((_) async {});
    when(() => local.cacheTokens(any())).thenAnswer((_) async {});
  });

  group('doctorRequestOtp', () {
    test('returns Right(null) on success', () async {
      when(() => remote.doctorRequestOtp('DR-001'))
          .thenAnswer((_) async {});

      final result = await repository.doctorRequestOtp('DR-001');

      expect(result, const Right(null));
    });

    test('returns Left(NetworkFailure) when offline', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);

      final result = await repository.doctorRequestOtp('DR-001');

      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f, isA<NetworkFailure>()),
        (_) => fail('Expected failure'),
      );
    });

    test('returns Left(ServerFailure) on ServerException', () async {
      when(() => remote.doctorRequestOtp(any()))
          .thenThrow(ServerException('Server error'));

      final result = await repository.doctorRequestOtp('DR-001');

      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f, isA<ServerFailure>()),
        (_) => fail('Expected failure'),
      );
    });
  });

  group('doctorVerifyOtp', () {
    test('returns Right with user and tokens on success', () async {
      when(() => remote.doctorVerifyOtp(
            badgeNumber: 'DR-001',
            otpCode: '123456',
          )).thenAnswer((_) async => (user: tUser, tokens: tTokens));

      final result = await repository.doctorVerifyOtp(
        badgeNumber: 'DR-001',
        otpCode: '123456',
      );

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected success'),
        (data) {
          expect(data.user.id, 'doc-1');
          expect(data.tokens.accessToken, 'access');
        },
      );
      verify(() => local.cacheUser(any())).called(1);
      verify(() => local.cacheTokens(any())).called(1);
    });

    test('returns Left(ServerFailure) on exception', () async {
      when(() => remote.doctorVerifyOtp(
            badgeNumber: any(named: 'badgeNumber'),
            otpCode: any(named: 'otpCode'),
          )).thenThrow(ServerException('Invalid OTP'));

      final result = await repository.doctorVerifyOtp(
        badgeNumber: 'DR-001',
        otpCode: 'bad',
      );

      expect(result.isLeft(), isTrue);
    });
  });

  group('getCurrentUser', () {
    test('returns cached user when available', () async {
      when(() => local.getCachedUser()).thenAnswer((_) async => tUser);

      final result = await repository.getCurrentUser();

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected success'),
        (user) => expect(user.id, 'doc-1'),
      );
    });

    test('returns Left(CacheFailure) when no cached user', () async {
      when(() => local.getCachedUser()).thenAnswer((_) async => null);

      final result = await repository.getCurrentUser();

      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f, isA<CacheFailure>()),
        (_) => fail('Expected failure'),
      );
    });
  });
}

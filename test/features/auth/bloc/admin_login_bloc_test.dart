import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:medimind_portal/core/error/failures.dart';
import 'package:medimind_portal/features/auth/domain/entities/admin_user.dart';
import 'package:medimind_portal/features/auth/domain/entities/auth_tokens.dart';
import 'package:medimind_portal/features/auth/domain/usecases/admin_login_usecase.dart';
import 'package:medimind_portal/features/auth/domain/usecases/admin_verify_otp_usecase.dart';
import 'package:medimind_portal/features/auth/presentation/bloc/admin_login/admin_login_bloc.dart';
import 'package:medimind_portal/features/auth/presentation/bloc/admin_login/admin_login_event.dart';
import 'package:medimind_portal/features/auth/presentation/bloc/admin_login/admin_login_state.dart';

class MockAdminLoginUseCase extends Mock implements AdminLoginUseCase {}

class MockAdminVerifyOtpUseCase extends Mock implements AdminVerifyOtpUseCase {}

void main() {
  late MockAdminLoginUseCase loginUseCase;
  late MockAdminVerifyOtpUseCase verifyOtpUseCase;

  final tUser = AdminUser(
    id: 'admin-1',
    fullName: 'Admin Tigist',
    email: 'tigist@clinic.et',
    centerId: 'center-1',
    centerName: 'Test Clinic',
  );
  final tTokens = AuthTokens(
    accessToken: 'access',
    refreshToken: 'refresh',
    expiresAt: DateTime.now().add(const Duration(hours: 1)),
  );

  setUp(() {
    loginUseCase = MockAdminLoginUseCase();
    verifyOtpUseCase = MockAdminVerifyOtpUseCase();
  });

  AdminLoginBloc buildBloc() => AdminLoginBloc(
        login: loginUseCase,
        verifyOtp: verifyOtpUseCase,
      );

  group('AdminLoginSubmitted', () {
    blocTest<AdminLoginBloc, AdminLoginState>(
      'emits [Loading, Success] when no 2FA required',
      build: buildBloc,
      setUp: () => when(
        () => loginUseCase(
            email: 'tigist@clinic.et', password: 'pass'),
      ).thenAnswer(
        (_) async => Right(
          (user: tUser, tokens: tTokens, requires2fa: false),
        ),
      ),
      act: (bloc) => bloc.add(const AdminLoginSubmitted(
          email: 'tigist@clinic.et', password: 'pass')),
      expect: () => [
        const AdminLoginLoading(),
        AdminLoginSuccess(user: tUser, tokens: tTokens),
      ],
    );

    blocTest<AdminLoginBloc, AdminLoginState>(
      'emits [Loading, Requires2fa] when 2FA needed',
      build: buildBloc,
      setUp: () => when(
        () => loginUseCase(
            email: 'tigist@clinic.et', password: 'pass'),
      ).thenAnswer(
        (_) async => Right(
          (user: tUser, tokens: tTokens, requires2fa: true),
        ),
      ),
      act: (bloc) => bloc.add(const AdminLoginSubmitted(
          email: 'tigist@clinic.et', password: 'pass')),
      expect: () => [
        const AdminLoginLoading(),
        const AdminLoginRequires2fa('tigist@clinic.et'),
      ],
    );

    blocTest<AdminLoginBloc, AdminLoginState>(
      'emits [Loading, Error] on failure',
      build: buildBloc,
      setUp: () => when(
        () => loginUseCase(email: any(named: 'email'), password: any(named: 'password')),
      ).thenAnswer((_) async => Left(ServerFailure('Unauthorized'))),
      act: (bloc) =>
          bloc.add(const AdminLoginSubmitted(email: 'x@y.et', password: 'bad')),
      expect: () => [
        const AdminLoginLoading(),
        const AdminLoginError('Unauthorized'),
      ],
    );
  });

  group('AdminOtpSubmitted', () {
    blocTest<AdminLoginBloc, AdminLoginState>(
      'emits [Loading, Success] on valid OTP',
      build: buildBloc,
      setUp: () => when(
        () => verifyOtpUseCase(
            email: 'tigist@clinic.et', otpCode: '123456'),
      ).thenAnswer((_) async => Right((user: tUser, tokens: tTokens))),
      act: (bloc) => bloc.add(
          const AdminOtpSubmitted(email: 'tigist@clinic.et', otpCode: '123456')),
      expect: () => [
        const AdminLoginLoading(),
        AdminLoginSuccess(user: tUser, tokens: tTokens),
      ],
    );

    blocTest<AdminLoginBloc, AdminLoginState>(
      'emits [Loading, Error] on invalid OTP',
      build: buildBloc,
      setUp: () => when(
        () => verifyOtpUseCase(
            email: any(named: 'email'), otpCode: any(named: 'otpCode')),
      ).thenAnswer((_) async => Left(ServerFailure('Invalid code'))),
      act: (bloc) => bloc.add(
          const AdminOtpSubmitted(email: 'a@b.et', otpCode: 'wrong')),
      expect: () => [
        const AdminLoginLoading(),
        const AdminLoginError('Invalid code'),
      ],
    );
  });

  group('AdminLoginReset', () {
    blocTest<AdminLoginBloc, AdminLoginState>(
      'emits [Initial] on reset',
      build: buildBloc,
      act: (bloc) => bloc.add(const AdminLoginReset()),
      expect: () => [const AdminLoginInitial()],
    );
  });
}

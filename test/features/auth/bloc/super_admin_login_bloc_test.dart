import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:medimind_portal/core/error/failures.dart';
import 'package:medimind_portal/features/auth/domain/entities/auth_tokens.dart';
import 'package:medimind_portal/features/auth/domain/entities/super_admin_user.dart';
import 'package:medimind_portal/features/auth/domain/usecases/super_admin_login_usecase.dart';
import 'package:medimind_portal/features/auth/domain/usecases/super_admin_verify_2fa_usecase.dart';
import 'package:medimind_portal/features/auth/presentation/bloc/super_admin_login/super_admin_login_bloc.dart';
import 'package:medimind_portal/features/auth/presentation/bloc/super_admin_login/super_admin_login_event.dart';
import 'package:medimind_portal/features/auth/presentation/bloc/super_admin_login/super_admin_login_state.dart';

class MockSuperAdminLoginUseCase extends Mock
    implements SuperAdminLoginUseCase {}

class MockSuperAdminVerify2faUseCase extends Mock
    implements SuperAdminVerify2faUseCase {}

void main() {
  late MockSuperAdminLoginUseCase loginUseCase;
  late MockSuperAdminVerify2faUseCase verify2faUseCase;

  final tUser = SuperAdminUser(
    id: 'sa-1',
    fullName: 'Super Admin',
    email: 'super@medimind.et',
  );
  final tTokens = AuthTokens(
    accessToken: 'access',
    refreshToken: 'refresh',
    expiresAt: DateTime.now().add(const Duration(hours: 1)),
  );

  setUp(() {
    loginUseCase = MockSuperAdminLoginUseCase();
    verify2faUseCase = MockSuperAdminVerify2faUseCase();
  });

  SuperAdminLoginBloc buildBloc() => SuperAdminLoginBloc(
        login: loginUseCase,
        verify2fa: verify2faUseCase,
      );

  group('SuperAdminLoginSubmitted', () {
    blocTest<SuperAdminLoginBloc, SuperAdminLoginState>(
      'emits [Loading, Requires2fa] on valid credentials',
      build: buildBloc,
      setUp: () => when(
        () => loginUseCase(
            email: 'super@medimind.et', password: 'pass'),
      ).thenAnswer(
          (_) async => Right((user: tUser, tokens: tTokens, requires2fa: true))),
      act: (bloc) => bloc.add(const SuperAdminLoginSubmitted(
          email: 'super@medimind.et', password: 'pass')),
      expect: () => [
        const SuperAdminLoginLoading(),
        const SuperAdminLoginRequires2fa('super@medimind.et'),
      ],
    );

    blocTest<SuperAdminLoginBloc, SuperAdminLoginState>(
      'emits [Loading, Error] on invalid credentials',
      build: buildBloc,
      setUp: () => when(
        () => loginUseCase(
            email: any(named: 'email'), password: any(named: 'password')),
      ).thenAnswer((_) async => Left(ServerFailure('Unauthorized'))),
      act: (bloc) => bloc.add(const SuperAdminLoginSubmitted(
          email: 'x@y.et', password: 'bad')),
      expect: () => [
        const SuperAdminLoginLoading(),
        const SuperAdminLoginError('Unauthorized'),
      ],
    );
  });

  group('SuperAdmin2faSubmitted', () {
    blocTest<SuperAdminLoginBloc, SuperAdminLoginState>(
      'emits [Loading, Success] on valid TOTP',
      build: buildBloc,
      setUp: () => when(
        () => verify2faUseCase(
            email: 'super@medimind.et', totpCode: '123456'),
      ).thenAnswer((_) async => Right((user: tUser, tokens: tTokens))),
      act: (bloc) => bloc.add(const SuperAdmin2faSubmitted(
          email: 'super@medimind.et', totpCode: '123456')),
      expect: () => [
        const SuperAdminLoginLoading(),
        SuperAdminLoginSuccess(user: tUser, tokens: tTokens),
      ],
    );

    blocTest<SuperAdminLoginBloc, SuperAdminLoginState>(
      'emits [Loading, Error] on invalid TOTP',
      build: buildBloc,
      setUp: () => when(
        () => verify2faUseCase(
            email: any(named: 'email'), totpCode: any(named: 'totpCode')),
      ).thenAnswer((_) async => Left(ServerFailure('Invalid TOTP'))),
      act: (bloc) => bloc.add(const SuperAdmin2faSubmitted(
          email: 'a@b.et', totpCode: 'wrong')),
      expect: () => [
        const SuperAdminLoginLoading(),
        const SuperAdminLoginError('Invalid TOTP'),
      ],
    );
  });

  group('SuperAdminLoginReset', () {
    blocTest<SuperAdminLoginBloc, SuperAdminLoginState>(
      'emits [Initial] on reset',
      build: buildBloc,
      act: (bloc) => bloc.add(const SuperAdminLoginReset()),
      expect: () => [const SuperAdminLoginInitial()],
    );
  });
}

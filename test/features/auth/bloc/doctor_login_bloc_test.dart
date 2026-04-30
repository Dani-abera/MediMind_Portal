import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:medimind_portal/core/error/failures.dart';
import 'package:medimind_portal/features/auth/domain/entities/auth_tokens.dart';
import 'package:medimind_portal/features/auth/domain/entities/doctor_user.dart';
import 'package:medimind_portal/features/auth/domain/usecases/doctor_request_otp_usecase.dart';
import 'package:medimind_portal/features/auth/domain/usecases/doctor_verify_otp_usecase.dart';
import 'package:medimind_portal/features/auth/presentation/bloc/doctor_login/doctor_login_bloc.dart';
import 'package:medimind_portal/features/auth/presentation/bloc/doctor_login/doctor_login_event.dart';
import 'package:medimind_portal/features/auth/presentation/bloc/doctor_login/doctor_login_state.dart';

class MockDoctorRequestOtpUseCase extends Mock
    implements DoctorRequestOtpUseCase {}

class MockDoctorVerifyOtpUseCase extends Mock
    implements DoctorVerifyOtpUseCase {}

void main() {
  late MockDoctorRequestOtpUseCase requestOtp;
  late MockDoctorVerifyOtpUseCase verifyOtp;

  final tUser = DoctorUser(
    id: 'doc-1',
    fullName: 'Dr. Abebe',
    email: 'abebe@medimind.et',
    badgeNumber: 'DR-001',
    specialization: 'General',
  );
  final tTokens = AuthTokens(
    accessToken: 'access',
    refreshToken: 'refresh',
    expiresAt: DateTime.now().add(const Duration(hours: 1)),
  );

  setUp(() {
    requestOtp = MockDoctorRequestOtpUseCase();
    verifyOtp = MockDoctorVerifyOtpUseCase();
  });

  DoctorLoginBloc buildBloc() => DoctorLoginBloc(
        requestOtp: requestOtp,
        verifyOtp: verifyOtp,
      );

  group('DoctorRequestOtp', () {
    blocTest<DoctorLoginBloc, DoctorLoginState>(
      'emits [RequestingOtp, OtpSent] on success',
      build: buildBloc,
      setUp: () => when(() => requestOtp('DR-001'))
          .thenAnswer((_) async => const Right(null)),
      act: (bloc) => bloc.add(const DoctorRequestOtp('DR-001')),
      expect: () => [
        const DoctorLoginRequestingOtp(),
        const DoctorLoginOtpSent('DR-001'),
      ],
    );

    blocTest<DoctorLoginBloc, DoctorLoginState>(
      'emits [RequestingOtp, Error] on failure',
      build: buildBloc,
      setUp: () => when(() => requestOtp('BAD'))
          .thenAnswer((_) async => Left(ServerFailure('Not found'))),
      act: (bloc) => bloc.add(const DoctorRequestOtp('BAD')),
      expect: () => [
        const DoctorLoginRequestingOtp(),
        const DoctorLoginError('Not found'),
      ],
    );
  });

  group('DoctorVerifyOtp', () {
    blocTest<DoctorLoginBloc, DoctorLoginState>(
      'emits [VerifyingOtp, Success] on valid OTP',
      build: buildBloc,
      setUp: () => when(
        () => verifyOtp(badgeNumber: 'DR-001', otpCode: '123456'),
      ).thenAnswer((_) async => Right((user: tUser, tokens: tTokens))),
      act: (bloc) => bloc
          .add(const DoctorVerifyOtp(badgeNumber: 'DR-001', otpCode: '123456')),
      expect: () => [
        const DoctorLoginVerifyingOtp(),
        DoctorLoginSuccess(user: tUser, tokens: tTokens),
      ],
    );

    blocTest<DoctorLoginBloc, DoctorLoginState>(
      'emits [VerifyingOtp, Error] on invalid OTP',
      build: buildBloc,
      setUp: () => when(
        () => verifyOtp(badgeNumber: 'DR-001', otpCode: 'wrong'),
      ).thenAnswer((_) async => Left(ServerFailure('Invalid OTP'))),
      act: (bloc) => bloc
          .add(const DoctorVerifyOtp(badgeNumber: 'DR-001', otpCode: 'wrong')),
      expect: () => [
        const DoctorLoginVerifyingOtp(),
        const DoctorLoginError('Invalid OTP'),
      ],
    );
  });

  group('DoctorLoginReset', () {
    blocTest<DoctorLoginBloc, DoctorLoginState>(
      'emits [Initial] when reset',
      build: buildBloc,
      act: (bloc) => bloc.add(const DoctorLoginReset()),
      expect: () => [const DoctorLoginInitial()],
    );
  });
}

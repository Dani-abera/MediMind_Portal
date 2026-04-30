import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:medimind_portal/features/auth/presentation/cubit/account_lockout_cubit.dart';

void main() {
  late AccountLockoutCubit cubit;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<AccountLockoutCubit> buildCubit() async {
    final prefs = await SharedPreferences.getInstance();
    return AccountLockoutCubit(prefs);
  }

  group('isLocked', () {
    test('returns false when no failures recorded', () async {
      cubit = await buildCubit();
      expect(cubit.isLocked('user@test.et'), isFalse);
    });

    test('returns false after 4 failures (below threshold)', () async {
      cubit = await buildCubit();
      for (var i = 0; i < 4; i++) {
        cubit.recordFailure('user@test.et');
      }
      expect(cubit.isLocked('user@test.et'), isFalse);
    });

    test('returns true after 5 failures', () async {
      cubit = await buildCubit();
      for (var i = 0; i < 5; i++) {
        cubit.recordFailure('user@test.et');
      }
      expect(cubit.isLocked('user@test.et'), isTrue);
    });
  });

  group('recordSuccess', () {
    test('clears lockout after success', () async {
      cubit = await buildCubit();
      for (var i = 0; i < 5; i++) {
        cubit.recordFailure('user@test.et');
      }
      expect(cubit.isLocked('user@test.et'), isTrue);
      cubit.recordSuccess('user@test.et');
      expect(cubit.isLocked('user@test.et'), isFalse);
    });

    test('clears failure count after success', () async {
      cubit = await buildCubit();
      for (var i = 0; i < 3; i++) {
        cubit.recordFailure('user@test.et');
      }
      cubit.recordSuccess('user@test.et');
      expect(cubit.failureCount('user@test.et'), 0);
    });
  });

  group('lockedUntil', () {
    test('returns null when not locked', () async {
      cubit = await buildCubit();
      expect(cubit.lockedUntil('user@test.et'), isNull);
    });

    test('returns a future DateTime when locked', () async {
      cubit = await buildCubit();
      for (var i = 0; i < 5; i++) {
        cubit.recordFailure('user@test.et');
      }
      final until = cubit.lockedUntil('user@test.et');
      expect(until, isNotNull);
      expect(until!.isAfter(DateTime.now()), isTrue);
    });
  });

  group('persistence', () {
    test('lockout persists across cubit instances via SharedPreferences',
        () async {
      final prefs = await SharedPreferences.getInstance();
      final first = AccountLockoutCubit(prefs);
      for (var i = 0; i < 5; i++) {
        first.recordFailure('persisted@test.et');
      }
      // New instance reads from prefs
      final second = AccountLockoutCubit(prefs);
      expect(second.isLocked('persisted@test.et'), isTrue);
    });
  });
}

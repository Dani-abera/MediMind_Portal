import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountLockoutState extends Equatable {
  final Map<String, int> failureCounts;
  final Map<String, DateTime> lockedUntil;

  const AccountLockoutState({
    this.failureCounts = const {},
    this.lockedUntil = const {},
  });

  AccountLockoutState copyWith({
    Map<String, int>? failureCounts,
    Map<String, DateTime>? lockedUntil,
  }) =>
      AccountLockoutState(
        failureCounts: failureCounts ?? this.failureCounts,
        lockedUntil: lockedUntil ?? this.lockedUntil,
      );

  @override
  List<Object?> get props => [failureCounts, lockedUntil];
}

class AccountLockoutCubit extends Cubit<AccountLockoutState> {
  static const int _maxAttempts = 5;
  static const Duration _lockDuration = Duration(minutes: 15);
  static const String _failuresPrefix = 'lockout_failures_';
  static const String _lockedUntilPrefix = 'lockout_until_';

  final SharedPreferences _prefs;

  AccountLockoutCubit(this._prefs) : super(const AccountLockoutState());

  bool isLocked(String identifier) {
    final until = state.lockedUntil[identifier];
    if (until == null) {
      // Check persisted
      final raw = _prefs.getString('$_lockedUntilPrefix$identifier');
      if (raw == null) return false;
      final dt = DateTime.tryParse(raw);
      if (dt == null) return false;
      if (DateTime.now().isBefore(dt)) return true;
      // Expired lock — clean up
      _prefs.remove('$_lockedUntilPrefix$identifier');
      _prefs.remove('$_failuresPrefix$identifier');
      return false;
    }
    return DateTime.now().isBefore(until);
  }

  DateTime? lockedUntil(String identifier) {
    final fromState = state.lockedUntil[identifier];
    if (fromState != null && DateTime.now().isBefore(fromState)) {
      return fromState;
    }
    final raw = _prefs.getString('$_lockedUntilPrefix$identifier');
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  int failureCount(String identifier) {
    return state.failureCounts[identifier] ??
        (_prefs.getInt('$_failuresPrefix$identifier') ?? 0);
  }

  void recordFailure(String identifier) {
    final count = failureCount(identifier) + 1;
    final newCounts = Map<String, int>.from(state.failureCounts)
      ..[identifier] = count;
    _prefs.setInt('$_failuresPrefix$identifier', count);

    Map<String, DateTime> newLocked =
        Map<String, DateTime>.from(state.lockedUntil);
    if (count >= _maxAttempts) {
      final until = DateTime.now().add(_lockDuration);
      newLocked[identifier] = until;
      _prefs.setString('$_lockedUntilPrefix$identifier', until.toIso8601String());
    }

    emit(state.copyWith(failureCounts: newCounts, lockedUntil: newLocked));
  }

  void recordSuccess(String identifier) {
    final newCounts = Map<String, int>.from(state.failureCounts)
      ..remove(identifier);
    final newLocked = Map<String, DateTime>.from(state.lockedUntil)
      ..remove(identifier);
    _prefs.remove('$_failuresPrefix$identifier');
    _prefs.remove('$_lockedUntilPrefix$identifier');
    emit(state.copyWith(failureCounts: newCounts, lockedUntil: newLocked));
  }
}

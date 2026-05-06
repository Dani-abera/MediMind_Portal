part of 'booking_rules_bloc.dart';

abstract class BookingRulesEvent extends Equatable {
  const BookingRulesEvent();
  @override
  List<Object?> get props => [];
}

class BookingRulesStarted extends BookingRulesEvent {
  final String centerId;
  const BookingRulesStarted(this.centerId);
  @override
  List<Object?> get props => [centerId];
}

class BookingRulesChanged extends BookingRulesEvent {
  final BookingRules rules;
  const BookingRulesChanged(this.rules);
  @override
  List<Object?> get props => [rules];
}

class BookingRulesSubmitted extends BookingRulesEvent {
  const BookingRulesSubmitted();
}

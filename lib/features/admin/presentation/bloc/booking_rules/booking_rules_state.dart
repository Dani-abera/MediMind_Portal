part of 'booking_rules_bloc.dart';

abstract class BookingRulesState extends Equatable {
  const BookingRulesState();
  @override
  List<Object?> get props => [];
}

class BookingRulesInitial extends BookingRulesState {
  const BookingRulesInitial();
}

class BookingRulesLoading extends BookingRulesState {
  const BookingRulesLoading();
}

class BookingRulesLoaded extends BookingRulesState {
  final BookingRules rules;
  const BookingRulesLoaded(this.rules);
  @override
  List<Object?> get props => [rules];
}

class BookingRulesSaving extends BookingRulesState {
  const BookingRulesSaving();
}

class BookingRulesSaved extends BookingRulesState {
  final String? warningMessage;
  const BookingRulesSaved({this.warningMessage});
  @override
  List<Object?> get props => [warningMessage];
}

class BookingRulesError extends BookingRulesState {
  final String message;
  const BookingRulesError(this.message);
  @override
  List<Object?> get props => [message];
}

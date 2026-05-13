import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import '../../../domain/entities/booking_rules.dart';
import '../../../domain/usecases/get_booking_rules_usecase.dart';
import '../../../domain/usecases/save_booking_rules_usecase.dart';

part 'booking_rules_event.dart';
part 'booking_rules_state.dart';

class BookingRulesBloc extends Bloc<BookingRulesEvent, BookingRulesState> {
  final GetBookingRulesUseCase _getBookingRules;
  final SaveBookingRulesUseCase _saveBookingRules;

  String _centerId = '';
  BookingRules _rules = const BookingRules();

  BookingRulesBloc({
    required GetBookingRulesUseCase getBookingRules,
    required SaveBookingRulesUseCase saveBookingRules,
  })  : _getBookingRules = getBookingRules,
        _saveBookingRules = saveBookingRules,
        super(const BookingRulesInitial()) {
    on<BookingRulesStarted>(_onStarted, transformer: droppable());
    on<BookingRulesChanged>(_onChanged);
    on<BookingRulesSubmitted>(_onSubmitted, transformer: droppable());
  }

  Future<void> _onStarted(BookingRulesStarted event, Emitter<BookingRulesState> emit) async {
    _centerId = event.centerId;
    emit(const BookingRulesLoading());
    final result = await _getBookingRules(_centerId);
    result.fold(
      (f) => emit(BookingRulesError(f.message)),
      (rules) {
        _rules = rules;
        emit(BookingRulesLoaded(rules));
      },
    );
  }

  void _onChanged(BookingRulesChanged event, Emitter<BookingRulesState> emit) {
    _rules = event.rules;
    emit(BookingRulesLoaded(_rules));
  }

  Future<void> _onSubmitted(BookingRulesSubmitted event, Emitter<BookingRulesState> emit) async {
    emit(const BookingRulesSaving());
    final result = await _saveBookingRules(_centerId, _rules);
    result.fold(
      (f) => emit(BookingRulesError(f.message)),
      (rules) {
        _rules = rules;
        emit(BookingRulesSaved(warningMessage: _rules.warning));
        emit(BookingRulesLoaded(_rules));
      },
    );
  }
}

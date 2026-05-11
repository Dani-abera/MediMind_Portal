import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import '../../../domain/entities/payment.dart';
import '../../../domain/entities/audit_entry.dart'; // PaymentFilters
import '../../../domain/usecases/get_payments_usecase.dart';

part 'payments_ledger_event.dart';
part 'payments_ledger_state.dart';

class PaymentsLedgerBloc extends Bloc<PaymentsLedgerEvent, PaymentsLedgerState> {
  final GetPaymentsUseCase _getPayments;
  final MarkPaymentResolvedUseCase _markResolved;
  final GetPaymentReceiptUseCase _getReceipt;

  String _centerId = '';
  PaymentFilters _filters = const PaymentFilters();
  int _page = 1;
  static const _pageSize = 20;

  PaymentsLedgerBloc({
    required GetPaymentsUseCase getPayments,
    required MarkPaymentResolvedUseCase markResolved,
    required GetPaymentReceiptUseCase getReceipt,
  })  : _getPayments = getPayments,
        _markResolved = markResolved,
        _getReceipt = getReceipt,
        super(const PaymentsLedgerInitial()) {
    on<PaymentsLedgerStarted>(_onStarted, transformer: droppable());
    on<PaymentsLedgerFiltered>(_onFiltered, transformer: droppable());
    on<PaymentsLedgerPageChanged>(_onPageChanged, transformer: droppable());
    on<PaymentReceiptRequested>(_onReceipt, transformer: droppable());
    on<PaymentResolveRequested>(_onResolve, transformer: droppable());
    on<PaymentsLedgerRefreshed>(_onRefreshed, transformer: droppable());
  }

  Future<void> _fetch(Emitter<PaymentsLedgerState> emit) async {
    final result = await _getPayments(
      _centerId,
      status: _filters.status,
      from: _filters.from,
      to: _filters.to,
      method: _filters.method,
      minAmount: _filters.minAmount,
      maxAmount: _filters.maxAmount,
      page: _page,
      pageSize: _pageSize,
    );
    result.fold(
      (f) => emit(PaymentsLedgerError(f.message)),
      (payments) => emit(PaymentsLedgerLoaded(payments: payments, filters: _filters, page: _page)),
    );
  }

  Future<void> _onStarted(PaymentsLedgerStarted event, Emitter<PaymentsLedgerState> emit) async {
    _centerId = event.centerId;
    emit(const PaymentsLedgerLoading());
    await _fetch(emit);
  }

  Future<void> _onFiltered(PaymentsLedgerFiltered event, Emitter<PaymentsLedgerState> emit) async {
    _filters = event.filters;
    _page = 1;
    emit(const PaymentsLedgerLoading());
    await _fetch(emit);
  }

  Future<void> _onPageChanged(PaymentsLedgerPageChanged event, Emitter<PaymentsLedgerState> emit) async {
    _page = event.page;
    emit(const PaymentsLedgerLoading());
    await _fetch(emit);
  }

  Future<void> _onReceipt(PaymentReceiptRequested event, Emitter<PaymentsLedgerState> emit) async {
    final result = await _getReceipt(event.paymentId);
    result.fold(
      (f) => emit(PaymentsLedgerError(f.message)),
      (url) => emit(PaymentsReceiptReady(url ?? '')),
    );
  }

  Future<void> _onResolve(PaymentResolveRequested event, Emitter<PaymentsLedgerState> emit) async {
    emit(const PaymentsActionInProgress());
    final result = await _markResolved(event.paymentId);
    await result.fold(
      (f) async => emit(PaymentsLedgerError(f.message)),
      (_) async {
        emit(const PaymentsActionSuccess('Payment marked as resolved'));
        await _fetch(emit);
      },
    );
  }

  Future<void> _onRefreshed(PaymentsLedgerRefreshed event, Emitter<PaymentsLedgerState> emit) async {
    emit(const PaymentsLedgerLoading());
    await _fetch(emit);
  }
}

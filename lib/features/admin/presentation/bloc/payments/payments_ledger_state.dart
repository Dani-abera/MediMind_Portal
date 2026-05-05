part of 'payments_ledger_bloc.dart';

abstract class PaymentsLedgerState extends Equatable {
  const PaymentsLedgerState();
  @override List<Object?> get props => [];
}

class PaymentsLedgerInitial extends PaymentsLedgerState { const PaymentsLedgerInitial(); }
class PaymentsLedgerLoading extends PaymentsLedgerState { const PaymentsLedgerLoading(); }

class PaymentsLedgerLoaded extends PaymentsLedgerState {
  final List<Payment> payments;
  final PaymentFilters filters;
  final int page;
  final int pageSize;
  final Set<String> selectedIds;
  const PaymentsLedgerLoaded({
    required this.payments,
    required this.filters,
    this.page = 1,
    this.pageSize = 20,
    this.selectedIds = const {},
  });
  PaymentsLedgerLoaded copyWith({List<Payment>? payments, Set<String>? selectedIds, int? page}) =>
      PaymentsLedgerLoaded(
        payments: payments ?? this.payments,
        filters: filters,
        page: page ?? this.page,
        pageSize: pageSize,
        selectedIds: selectedIds ?? this.selectedIds,
      );
  @override List<Object?> get props => [payments, filters, page, pageSize, selectedIds];
}

class PaymentsLedgerError extends PaymentsLedgerState {
  final String message;
  const PaymentsLedgerError(this.message);
  @override List<Object?> get props => [message];
}

class PaymentsActionInProgress extends PaymentsLedgerState { const PaymentsActionInProgress(); }
class PaymentsActionSuccess extends PaymentsLedgerState {
  final String message;
  const PaymentsActionSuccess(this.message);
  @override List<Object?> get props => [message];
}

class PaymentsReceiptReady extends PaymentsLedgerState {
  final String url;
  const PaymentsReceiptReady(this.url);
  @override List<Object?> get props => [url];
}

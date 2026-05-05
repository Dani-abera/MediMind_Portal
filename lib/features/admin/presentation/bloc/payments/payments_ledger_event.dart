part of 'payments_ledger_bloc.dart';

abstract class PaymentsLedgerEvent extends Equatable {
  const PaymentsLedgerEvent();
  @override List<Object?> get props => [];
}

class PaymentsLedgerStarted extends PaymentsLedgerEvent {
  final String centerId;
  const PaymentsLedgerStarted(this.centerId);
  @override List<Object?> get props => [centerId];
}

class PaymentsLedgerFiltered extends PaymentsLedgerEvent {
  final PaymentFilters filters;
  const PaymentsLedgerFiltered(this.filters);
  @override List<Object?> get props => [filters];
}

class PaymentsLedgerPageChanged extends PaymentsLedgerEvent {
  final int page;
  const PaymentsLedgerPageChanged(this.page);
  @override List<Object?> get props => [page];
}

class PaymentReceiptRequested extends PaymentsLedgerEvent {
  final String paymentId;
  const PaymentReceiptRequested(this.paymentId);
  @override List<Object?> get props => [paymentId];
}

class PaymentResolveRequested extends PaymentsLedgerEvent {
  final String paymentId;
  const PaymentResolveRequested(this.paymentId);
  @override List<Object?> get props => [paymentId];
}

class PaymentsLedgerRefreshed extends PaymentsLedgerEvent {
  const PaymentsLedgerRefreshed();
}

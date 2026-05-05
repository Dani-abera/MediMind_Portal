import 'package:equatable/equatable.dart';

enum PaymentMethod {
  mobileMoney, card, cash, insurance, unknown;

  String get label => switch (this) {
    PaymentMethod.mobileMoney => 'Mobile Money',
    PaymentMethod.card        => 'Card',
    PaymentMethod.cash        => 'Cash',
    PaymentMethod.insurance   => 'Insurance',
    PaymentMethod.unknown     => 'Unknown',
  };

  static PaymentMethod fromString(String? s) => switch (s?.toLowerCase()) {
    'mobile_money' || 'mobilemoney' || 'telebirr' => PaymentMethod.mobileMoney,
    'card' || 'credit_card' || 'debit_card'       => PaymentMethod.card,
    'cash'                                         => PaymentMethod.cash,
    'insurance'                                    => PaymentMethod.insurance,
    _                                              => PaymentMethod.unknown,
  };
}

enum AdminPaymentStatus {
  pending, completed, failed, refunded, unknown;

  String get label => switch (this) {
    AdminPaymentStatus.pending   => 'Pending',
    AdminPaymentStatus.completed => 'Completed',
    AdminPaymentStatus.failed    => 'Failed',
    AdminPaymentStatus.refunded  => 'Refunded',
    AdminPaymentStatus.unknown   => 'Unknown',
  };

  static AdminPaymentStatus fromString(String? s) => switch (s?.toLowerCase()) {
    'pending'   => AdminPaymentStatus.pending,
    'completed' || 'paid' || 'success' => AdminPaymentStatus.completed,
    'failed'    => AdminPaymentStatus.failed,
    'refunded'  => AdminPaymentStatus.refunded,
    _           => AdminPaymentStatus.unknown,
  };
}

class Payment extends Equatable {
  final String id;
  final String ref;
  final DateTime date;
  final String patientName;
  final String patientId;
  final String doctorName;
  final String doctorId;
  final double amount;
  final PaymentMethod method;
  final AdminPaymentStatus status;
  final String? receiptUrl;
  final String? appointmentId;
  final String? notes;

  const Payment({
    required this.id,
    required this.ref,
    required this.date,
    required this.patientName,
    required this.patientId,
    required this.doctorName,
    required this.doctorId,
    required this.amount,
    required this.method,
    required this.status,
    this.receiptUrl,
    this.appointmentId,
    this.notes,
  });

  @override
  List<Object?> get props => [id, ref, date, patientName, patientId, doctorName,
    doctorId, amount, method, status, receiptUrl, appointmentId];
}

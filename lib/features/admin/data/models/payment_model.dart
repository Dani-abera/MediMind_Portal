import '../../domain/entities/payment.dart';

class PaymentModel extends Payment {
  const PaymentModel({
    required super.id,
    required super.ref,
    required super.date,
    required super.patientName,
    required super.patientId,
    required super.doctorName,
    required super.doctorId,
    required super.amount,
    required super.method,
    required super.status,
    super.receiptUrl,
    super.appointmentId,
    super.notes,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> j) => PaymentModel(
        id: j['paymentId'] as String? ?? j['id'] as String? ?? '',
        ref: j['paymentRef'] as String? ?? j['ref'] as String? ?? j['payment_ref'] as String? ?? '',
        date: DateTime.tryParse(
              j['paymentDate'] as String? ??
              j['createdAt'] as String? ??
              j['date'] as String? ??
              j['created_at'] as String? ?? '') ??
            DateTime.now(),
        patientName: j['patientName'] as String? ?? j['patient_name'] as String? ?? '',
        patientId: j['patientId'] as String? ?? j['patient_id'] as String? ?? '',
        doctorName: j['doctorName'] as String? ?? j['doctor_name'] as String? ?? '',
        doctorId: j['doctorId'] as String? ?? j['doctor_id'] as String? ?? '',
        amount: (j['amount'] as num?)?.toDouble() ?? 0,
        method: PaymentMethod.fromString(
            j['paymentMethod'] as String? ?? j['method'] as String?),
        status: AdminPaymentStatus.fromString(j['status'] as String?),
        receiptUrl: j['receiptUrl'] as String? ?? j['receipt_url'] as String?,
        appointmentId: (j['appointmentId'] as String?)?.isNotEmpty == true
            ? j['appointmentId'] as String
            : (j['appointment_id'] as String?),
        notes: j['notes'] as String?,
      );
}

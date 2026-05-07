import 'package:sentry_flutter/sentry_flutter.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._();
  factory AnalyticsService() => _instance;
  AnalyticsService._();

  Future<void> logScreenView(String screenName) async {
    await Sentry.addBreadcrumb(
      Breadcrumb(
        category: 'navigation',
        message: screenName,
        type: 'navigation',
        data: {'screen': screenName},
      ),
    );
  }

  Future<void> logLoginSuccess(String userType) async {
    await _log('login_success', {'user_type': userType});
  }

  Future<void> logAppointmentApproved(String appointmentId) async {
    await _log('appointment_approved', {'appointment_id': appointmentId});
  }

  Future<void> logDoctorAdded(String doctorId) async {
    await _log('doctor_added', {'doctor_id': doctorId});
  }

  Future<void> logCenterApproved(String centerId) async {
    await _log('center_approved', {'center_id': centerId});
  }

  Future<void> logPrescriptionIssued(String prescriptionId) async {
    await _log('prescription_issued', {'prescription_id': prescriptionId});
  }

  Future<void> logExportGenerated(String type, String format) async {
    await _log('export_generated', {'type': type, 'format': format});
  }

  Future<void> logBulkAction(String type, int count) async {
    await _log('bulk_action_executed', {'type': type, 'count': count});
  }

  Future<void> logQueueCallNext(String queueId) async {
    await _log('queue_call_next', {'queue_id': queueId});
  }

  Future<void> _log(String event, Map<String, dynamic> data) async {
    await Sentry.addBreadcrumb(
      Breadcrumb(
        category: 'event',
        message: event,
        data: data,
        level: SentryLevel.info,
      ),
    );
  }
}

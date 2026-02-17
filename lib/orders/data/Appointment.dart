
enum AppointmentStatus {
  pendingPayment,
  confirmed,
  cancelled,
  completed,
  refunded;

  static AppointmentStatus fromString(String value) {
    switch (value) {
      case 'pending_payment':
        return AppointmentStatus.pendingPayment;
      case 'confirmed':
        return AppointmentStatus.confirmed;
      case 'cancelled':
        return AppointmentStatus.cancelled;
      case 'completed':
        return AppointmentStatus.completed;
      case 'refunded':
        return AppointmentStatus.refunded;
      default:
        return AppointmentStatus.pendingPayment;
    }
  }

  String get label {
    switch (this) {
      case AppointmentStatus.pendingPayment:
        return 'Pending Payment';
      case AppointmentStatus.confirmed:
        return 'Confirmed';
      case AppointmentStatus.cancelled:
        return 'Cancelled';
      case AppointmentStatus.completed:
        return 'Completed';
      case AppointmentStatus.refunded:
        return 'Refunded';
    }
  }
}

class Appointment {
  final String id;
  final String userId;
  final String doctorId;
  final DateTime startsAt;
  final DateTime endsAt;
  final AppointmentStatus status;
  final String? patientNote;
  final String? adminNote;
  final int feeCents;
  final String currency;
  final DateTime createdAt;
  final DateTime updatedAt;

   final String? doctorName;
  final String? doctorTitle;
  final String? doctorPhotoPath;
  final String? clinicName;
  final String? clinicAddress;

  const Appointment({
    required this.id,
    required this.userId,
    required this.doctorId,
    required this.startsAt,
    required this.endsAt,
    required this.status,
    this.patientNote,
    this.adminNote,
    required this.feeCents,
    required this.currency,
    required this.createdAt,
    required this.updatedAt,
    this.doctorName,
    this.doctorTitle,
    this.doctorPhotoPath,
    this.clinicName,
    this.clinicAddress,
  });

  double get feeAmount => feeCents / 100.0;

  Duration get duration => endsAt.difference(startsAt);
}
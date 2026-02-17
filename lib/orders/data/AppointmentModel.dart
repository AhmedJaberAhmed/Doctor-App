import 'Appointment.dart';

class AppointmentModel extends Appointment {
  const AppointmentModel({
    required super.id,
    required super.userId,
    required super.doctorId,
    required super.startsAt,
    required super.endsAt,
    required super.status,
    super.patientNote,
    super.adminNote,
    required super.feeCents,
    required super.currency,
    required super.createdAt,
    required super.updatedAt,
    super.doctorName,
    super.doctorTitle,
    super.doctorPhotoPath,
    super.clinicName,
    super.clinicAddress,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {

    final doctor = json['doctors'] as Map<String, dynamic>?;

    return AppointmentModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      doctorId: json['doctor_id'] as String,
      startsAt: DateTime.parse(json['starts_at'] as String),
      endsAt: DateTime.parse(json['ends_at'] as String),
      status: AppointmentStatus.fromString(json['status'] as String),
      patientNote: json['patient_note'] as String?,
      adminNote: json['admin_note'] as String?,
      feeCents: json['fee_cents'] as int,
      currency: json['currency'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      doctorName: doctor?['full_name'] as String?,
      doctorTitle: doctor?['title'] as String?,
      doctorPhotoPath: doctor?['photo_path'] as String?,
      clinicName: doctor?['clinic_name'] as String?,
      clinicAddress: doctor?['clinic_address'] as String?,
    );
  }
}




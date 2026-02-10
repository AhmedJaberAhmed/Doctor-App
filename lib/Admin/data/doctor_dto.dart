
import '../domain/doctor.dart';

class DoctorDto {
  final String id;
  final String fullName;
  final String? title;
  final String? bio;
  final int consultationFeeCents;
  final String currency;
  final String? clinicName;
  final String? clinicAddress;
  final String? city;
  final String? photoPath;
  final bool isActive;

  DoctorDto({
    required this.id,
    required this.fullName,
    required this.title,
    required this.bio,
    required this.consultationFeeCents,
    required this.currency,
    required this.clinicName,
    required this.clinicAddress,
    required this.city,
    required this.photoPath,
    required this.isActive,
  });

  factory DoctorDto.fromJson(Map<String, dynamic> json) {
    return DoctorDto(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      title: json['title'] as String?,
      bio: json['bio'] as String?,
      consultationFeeCents: (json['consultation_fee_cents'] as num).toInt(),
      currency: (json['currency'] as String?) ?? 'USD',
      clinicName: json['clinic_name'] as String?,
      clinicAddress: json['clinic_address'] as String?,
      city: json['city'] as String?,
      photoPath: json['photo_path'] as String?,
      isActive: (json['is_active'] as bool?) ?? true,
    );
  }

    DoctorAdmin toEntity() => DoctorAdmin(
    id: id,
    fullName: fullName,
    title: title,
    bio: bio,
    consultationFeeCents: consultationFeeCents,
    currency: currency,
    clinicName: clinicName,
    clinicAddress: clinicAddress,
    city: city,
    photoPath: photoPath,
    isActive: isActive,
  );
}

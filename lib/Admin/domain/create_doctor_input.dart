import 'Availability.dart';

class CreateDoctorInput {
  final String fullName;
  final String? title;
  final String? phone; // ✅ add this

  final String? bio;
  final int consultationFeeCents;
  final String currency;
  final String? clinicName;
  final String? clinicAddress;
  final String? city;

  final List<String> categoryIds;
  final List<Availability> availability;

  /// Optional photo bytes (from image_picker)
  final List<int>? photoBytes;
  final String? photoFileExt; // "jpg", "png"

  const CreateDoctorInput({
    required this.fullName,
    required this.consultationFeeCents,
    required this.currency,
    required this.categoryIds,
    required this.availability,
    this.title,
    this.phone, // ✅

    this.bio,
    this.clinicName,
    this.clinicAddress,
    this.city,
    this.photoBytes,
    this.photoFileExt,
  });
}

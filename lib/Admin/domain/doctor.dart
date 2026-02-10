class DoctorAdmin {
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

  const DoctorAdmin({
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
}

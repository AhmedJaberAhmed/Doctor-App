class Doctor {
  final String id;
  final String fullName;
  final String? title;
  final String? bio;
  final String? phone;
  final String? email;
  final String? clinicName;
  final String? clinicAddress;
  final String? city;
  final int consultationFeeCents;
  final String currency;
  final String? photoPath;
  final double ratingAvg;
  final int ratingCount;

  const Doctor({
    required this.id,
    required this.fullName,
    required this.consultationFeeCents,
    required this.currency,
    required this.ratingAvg,
    required this.ratingCount,
    this.title,
    this.bio,
    this.phone,
    this.email,
    this.clinicName,
    this.clinicAddress,
    this.city,
    this.photoPath,
  });
}

class FavouriteDoctor {
  final String id;
  final String userId;
  final String doctorId;
  final String fullName;
  final String? title;
  final String? city;
  final String? clinicName;
  final String? photoPath;
  final double ratingAvg;
  final int ratingCount;
  final int consultationFeeCents;
  final String currency;
  final DateTime createdAt;

  FavouriteDoctor({
    required this.id,
    required this.userId,
    required this.doctorId,
    required this.fullName,
    this.title,
    this.city,
    this.clinicName,
    this.photoPath,
    required this.ratingAvg,
    required this.ratingCount,
    required this.consultationFeeCents,
    required this.currency,
    required this.createdAt,
  });

  factory FavouriteDoctor.fromMap(Map<String, dynamic> map) {
    return FavouriteDoctor(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      doctorId: map['doctor_id'] as String,
      fullName: map['full_name'] as String,
      title: map['title'] as String?,
      city: map['city'] as String?,
      clinicName: map['clinic_name'] as String?,
      photoPath: map['photo_path'] as String?,
      ratingAvg: map['rating_avg'] as double,
      ratingCount: map['rating_count'] as int,
      consultationFeeCents: map['consultation_fee_cents'] as int,
      currency: map['currency'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'doctor_id': doctorId,
      'full_name': fullName,
      'title': title,
      'city': city,
      'clinic_name': clinicName,
      'photo_path': photoPath,
      'rating_avg': ratingAvg,
      'rating_count': ratingCount,
      'consultation_fee_cents': consultationFeeCents,
      'currency': currency,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
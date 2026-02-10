
import '../domain/Profile.dart';

class ProfileModel extends Profile {
  const ProfileModel({
    required super.id,
    required super.role,
    super.fullName,
    super.phone,
  });

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      id: map['id'] as String,
      fullName: map['full_name'] as String?,
      phone: map['phone'] as String?,
      role: (map['role'] as String?) ?? 'user',
    );
  }

  Map<String, dynamic> toUpsertMap() {
    return {
      'id': id,
      'full_name': fullName,
      'phone': phone,
      'role': role,
    };
  }
}

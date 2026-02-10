class Profile {
  final String id;
  final String? fullName;
  final String? phone;
  final String role; // 'user' | 'admin'

  const Profile({
    required this.id,
    required this.role,
    this.fullName,
    this.phone,
  });
}

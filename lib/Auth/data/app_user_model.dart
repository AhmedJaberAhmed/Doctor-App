
import '../domain/AppUser.dart';

class AppUserModel extends AppUser {
  const AppUserModel({required super.id, super.email});

  factory AppUserModel.fromSupabaseUser(String id, String? email) {
    return AppUserModel(id: id, email: email);
  }
}

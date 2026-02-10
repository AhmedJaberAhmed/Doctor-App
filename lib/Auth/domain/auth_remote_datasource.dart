import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/profile_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  });

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  });

  Future<void> signOut();

  User? currentUser();

  Future<ProfileModel> fetchProfile(String userId);

  Future<ProfileModel> upsertProfile(ProfileModel profile);
}

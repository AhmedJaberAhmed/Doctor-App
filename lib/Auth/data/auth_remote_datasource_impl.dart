import 'package:doctor_app/Auth/data/profile_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/auth_remote_datasource.dart';


class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabase;
  AuthRemoteDataSourceImpl({required this.supabase});

  @override
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) {
    return supabase.auth.signUp(email: email, password: password);
  }

  @override
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return supabase.auth.signInWithPassword(email: email, password: password);
  }

  @override
  Future<void> signOut() => supabase.auth.signOut();

  @override
  User? currentUser() => supabase.auth.currentUser;

  @override
  Future<ProfileModel> fetchProfile(String userId) async {
    final data = await supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();

    return ProfileModel.fromMap(data);
  }

  @override
  Future<ProfileModel> upsertProfile(ProfileModel profile) async {
    final data = await supabase
        .from('profiles')
        .upsert(profile.toUpsertMap())
        .select()
        .single();

    return ProfileModel.fromMap(data);
  }
}

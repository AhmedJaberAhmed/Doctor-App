

import 'package:doctor_app/Auth/data/profile_model.dart';

import '../AuthResult.dart';
import '../domain/auth_remote_datasource.dart';
import '../failure.dart';
import 'app_user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;
  AuthRepositoryImpl(this.remote);

  @override
  Future<Either<Failure, AuthResult>> signUp({
    required String email,
    required String password,
    String? fullName,
    String? phone,
  }) async {
    try {
      final res = await remote.signUp(email: email, password: password);
      final user = res.user;
      if (user == null) {
        return Left(Failure('Sign up failed: user is null (check email confirmation settings).'));
      }

      // Ensure profiles row exists (your schema expects profiles.id = auth.users.id)
      final upserted = await remote.upsertProfile(
        ProfileModel(
          id: user.id,
          fullName: fullName,
          phone: phone,
          role: 'user',
        ),
      );

      return Right(
        AuthResult(
          user: AppUserModel.fromSupabaseUser(user.id, user.email),
          profile: upserted,
        ),
      );
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthResult>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final res = await remote.signIn(email: email, password: password);
      final user = res.user;
      if (user == null) {
        return Left(Failure('Sign in failed.'));
      }

      // fetch profile
      final profile = await remote.fetchProfile(user.id);

      return Right(
        AuthResult(
          user: AppUserModel.fromSupabaseUser(user.id, user.email),
          profile: profile,
        ),
      );
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await remote.signOut();
      return Right(null);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthResult?>> getCurrent() async {
    try {
      final user = remote.currentUser();
      if (user == null) return Right(null);

      final profile = await remote.fetchProfile(user.id);

      return Right(
        AuthResult(
          user: AppUserModel.fromSupabaseUser(user.id, user.email),
          profile: profile,
        ),
      );
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}

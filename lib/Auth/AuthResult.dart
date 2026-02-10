
import 'domain/AppUser.dart';
import 'domain/Profile.dart';
import 'failure.dart';

class AuthResult {
  final AppUser user;
  final Profile profile;
  const AuthResult({required this.user, required this.profile});
}

abstract class AuthRepository {
  Future<Either<Failure, AuthResult>> signUp({
    required String email,
    required String password,
    String? fullName,
    String? phone,
  });

  Future<Either<Failure, AuthResult>> signIn({
    required String email,
    required String password,
  });

  Future<Either<Failure, void>> signOut();

  /// returns null if no session
  Future<Either<Failure, AuthResult?>> getCurrent();
}

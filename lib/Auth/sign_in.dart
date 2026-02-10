
import 'AuthResult.dart';
import 'failure.dart';

class SignIn {
  final AuthRepository repo;
  SignIn(this.repo);

  Future<Either<Failure, AuthResult>> call({
    required String email,
    required String password,
  }) {
    return repo.signIn(email: email, password: password);
  }
}

class SignOut {
  final AuthRepository repo;
  SignOut(this.repo);

  Future<Either<Failure, void>> call() => repo.signOut();
}
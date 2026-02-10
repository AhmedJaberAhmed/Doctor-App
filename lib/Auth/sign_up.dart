
import 'AuthResult.dart';
import 'failure.dart';

class SignUp {
  final AuthRepository repo;
  SignUp(this.repo);

  Future<Either<Failure, AuthResult>> call({
    required String email,
    required String password,
    String? fullName,
    String? phone,
  }) {
    return repo.signUp(
      email: email,
      password: password,
      fullName: fullName,
      phone: phone,
    );
  }
}

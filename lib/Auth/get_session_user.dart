
import 'AuthResult.dart';
import 'failure.dart';

class GetSessionUser {
  final AuthRepository repo;
  GetSessionUser(this.repo);

  Future<Either<Failure, AuthResult?>> call() => repo.getCurrent();
}

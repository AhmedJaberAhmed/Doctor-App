
import 'category.dart';
import 'home_repository.dart';

class GetCategories {
  final HomeRepository repo;
  GetCategories(this.repo);
  Future<List<Category>> call() => repo.getCategories();
}

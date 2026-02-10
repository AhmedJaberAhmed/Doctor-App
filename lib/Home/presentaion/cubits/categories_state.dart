
import '../../domain/category.dart';

sealed class CategoriesState {
  const CategoriesState();
}

class CategoriesInitial extends CategoriesState {
  const CategoriesInitial();
}

class CategoriesLoading extends CategoriesState {
  const CategoriesLoading();
}

class CategoriesLoaded extends CategoriesState {
  final List<Category> categories;
  final String selectedCategoryId;
  const CategoriesLoaded({required this.categories, required this.selectedCategoryId});
}

class CategoriesError extends CategoriesState {
  final String message;
  const CategoriesError(this.message);
}

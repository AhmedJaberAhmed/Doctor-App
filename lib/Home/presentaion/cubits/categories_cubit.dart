import 'package:flutter_bloc/flutter_bloc.dart';
 import '../../domain/get_categories.dart';
import 'categories_state.dart';

class CategoriesCubit extends Cubit<CategoriesState> {
  final GetCategories getCategories;
  CategoriesCubit({required this.getCategories}) : super(const CategoriesInitial());

  Future<void> load() async {
    emit(const CategoriesLoading());
    try {
      final cats = await getCategories();
      if (cats.isEmpty) {
        emit(const CategoriesError('No categories found.'));
        return;
      }
      emit(CategoriesLoaded(categories: cats, selectedCategoryId: cats.first.id));
    } catch (e) {
      emit(CategoriesError(e.toString()));
    }
  }

  void select(String categoryId) {
    final s = state;
    if (s is CategoriesLoaded) {
      emit(CategoriesLoaded(categories: s.categories, selectedCategoryId: categoryId));
    }
  }
}

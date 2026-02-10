import 'package:flutter_bloc/flutter_bloc.dart';
 import '../../domain/get_doctors_by_category.dart';
import 'doctors_state.dart';

class DoctorsCubit extends Cubit<DoctorsState> {
  final GetDoctorsByCategory getDoctorsByCategory;
  DoctorsCubit({required this.getDoctorsByCategory}) : super(const DoctorsInitial());

  Future<void> load(String categoryId) async {
    emit(const DoctorsLoading());
    try {
      final docs = await getDoctorsByCategory(categoryId);
      emit(DoctorsLoaded(docs));
    } catch (e) {
      emit(DoctorsError(e.toString()));
    }
  }
}

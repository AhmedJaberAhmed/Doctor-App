import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../create_doctor_usecase.dart';
import '../../../domain/create_doctor_input.dart';
import 'admin_add_doctor_state.dart';

class AdminAddDoctorCubit extends Cubit<AdminAddDoctorState> {
  final CreateDoctorUseCase createDoctor;

  AdminAddDoctorCubit({required this.createDoctor})
      : super(const AdminAddDoctorInitial());

  Future<void> submit(CreateDoctorInput input) async {
    emit(const AdminAddDoctorLoading());
    try {
      final doctor = await createDoctor(input);
      emit(AdminAddDoctorSuccess(doctor));
    } catch (e) {
      emit(AdminAddDoctorError(e.toString()));
    }
  }
}

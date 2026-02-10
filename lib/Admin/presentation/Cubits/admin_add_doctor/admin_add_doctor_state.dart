
import '../../../domain/doctor.dart';

sealed class AdminAddDoctorState {
  const AdminAddDoctorState();
}

class AdminAddDoctorInitial extends AdminAddDoctorState {
  const AdminAddDoctorInitial();
}

class AdminAddDoctorLoading extends AdminAddDoctorState {
  const AdminAddDoctorLoading();
}

class AdminAddDoctorSuccess extends AdminAddDoctorState {
  final DoctorAdmin doctor;
  const AdminAddDoctorSuccess(this.doctor);
}

class AdminAddDoctorError extends AdminAddDoctorState {
  final String message;
  const AdminAddDoctorError(this.message);
}

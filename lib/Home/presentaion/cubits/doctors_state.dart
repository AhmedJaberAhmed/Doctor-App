
import '../../domain/Doctor.dart';

sealed class DoctorsState {
  const DoctorsState();
}

class DoctorsInitial extends DoctorsState {
  const DoctorsInitial();
}

class DoctorsLoading extends DoctorsState {
  const DoctorsLoading();
}

class DoctorsLoaded extends DoctorsState {
  final List<Doctor> doctors;
  const DoctorsLoaded(this.doctors);
}

class DoctorsError extends DoctorsState {
  final String message;
  const DoctorsError(this.message);
}

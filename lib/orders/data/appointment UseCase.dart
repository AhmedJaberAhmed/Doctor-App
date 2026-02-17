
import 'Appointment.dart';
import 'AppointmentRepositories.dart';

class GetUserAppointmentsUseCase {
  final AppointmentRepository _repository;

  GetUserAppointmentsUseCase(this._repository);

  Future<List<Appointment>> call({AppointmentStatus? statusFilter}) {
    return _repository.getUserAppointments(statusFilter: statusFilter);
  }
}


class CancelAppointmentUseCase {
  final AppointmentRepository _repository;

  CancelAppointmentUseCase(this._repository);

  Future<void> call(String appointmentId) {
    return _repository.cancelAppointment(appointmentId);
  }
}


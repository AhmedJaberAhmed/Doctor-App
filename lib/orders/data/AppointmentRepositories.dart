


import 'Appointment.dart';

abstract class AppointmentRepository {
   Future<List<Appointment>> getUserAppointments({
    AppointmentStatus? statusFilter,
  });

   Future<void> cancelAppointment(String appointmentId);
}













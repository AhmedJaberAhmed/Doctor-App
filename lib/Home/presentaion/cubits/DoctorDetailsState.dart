

import '../../domain/Doctor.dart';
import '../../domain/booking_slot.dart';

sealed class DoctorDetailsState {
  const DoctorDetailsState();
}

class DoctorDetailsLoading extends DoctorDetailsState {
  const DoctorDetailsLoading();
}

class DoctorDetailsLoaded extends DoctorDetailsState {
  final Doctor doctor;
  final List<BookingSlot> slots; // generated
  const DoctorDetailsLoaded({required this.doctor, required this.slots});
}

class DoctorDetailsError extends DoctorDetailsState {
  final String message;
  const DoctorDetailsError(this.message);
}

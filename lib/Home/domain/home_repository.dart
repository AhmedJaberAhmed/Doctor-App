

import '../presentaion/cubits/get_doctor_booked_appointments.dart';
import 'AvailabilityRule.dart';
import 'Doctor.dart';
import 'category.dart';

abstract class HomeRepository {
  Future<List<Category>> getCategories();
  Future<List<Doctor>> getDoctorsByCategory(String categoryId);
  Future<Doctor> getDoctorDetails(String doctorId);
  Future<List<AvailabilityRule>> getDoctorAvailability(String doctorId);

  Future<void> bookAppointment({
    required String userId,
    required String doctorId,
    required DateTime startsAt,
    required DateTime endsAt,
    String? patientNote,
    required int feeCents,
    required String currency,
  });
  Future<List<Map<String, DateTime>>> getBookedRanges({
    required String doctorId,
    required DateTime from,
    required DateTime to,
  });

  Future<List<BookedRange>> getDoctorBookedAppointments({
    required String doctorId,
    required DateTime from,
    required DateTime to,
  });

}

abstract class HomeRemoteDataSource {
  Future<List<Map<String, dynamic>>> getCategories();
  Future<List<Map<String, dynamic>>> getDoctorsByCategory(String categoryId);
  Future<Map<String, dynamic>> getDoctorDetails(String doctorId);
  Future<List<Map<String, dynamic>>> getDoctorAvailability(String doctorId);

  Future<void> bookAppointment({
    required String userId,
    required String doctorId,
    required DateTime startsAt,
    required DateTime endsAt,
    String? patientNote,
    required int feeCents,
    required String currency,
  });

  Future<List<Map<String, dynamic>>> getDoctorBookedAppointments({
    required String doctorId,
    required DateTime from,
    required DateTime to,
  });

}


import '../../domain/home_repository.dart';

class BookedRange {
  final DateTime start;
  final DateTime end;

  const BookedRange({required this.start, required this.end});
}

class GetDoctorBookedAppointments {
  final HomeRepository repo;
  GetDoctorBookedAppointments(this.repo);

  Future<List<BookedRange>> call({
    required String doctorId,
    required DateTime from,
    required DateTime to,
  }) {
    return repo.getDoctorBookedAppointments(
      doctorId: doctorId,
      from: from,
      to: to,
    );
  }
}

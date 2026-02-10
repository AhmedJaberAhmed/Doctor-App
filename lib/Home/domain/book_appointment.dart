
import 'home_repository.dart';

class BookAppointment {
  final HomeRepository repo;
  BookAppointment(this.repo);

  Future<void> call({
    required String userId,
    required String doctorId,
    required DateTime startsAt,
    required DateTime endsAt,
    String? patientNote,
    required int feeCents,
    required String currency,
  }) {
    return repo.bookAppointment(
      userId: userId,
      doctorId: doctorId,
      startsAt: startsAt,
      endsAt: endsAt,
      patientNote: patientNote,
      feeCents: feeCents,
      currency: currency,
    );
  }
}

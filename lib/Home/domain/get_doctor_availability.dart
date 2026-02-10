

import 'AvailabilityRule.dart';
import 'home_repository.dart';

class GetDoctorAvailability {
  final HomeRepository repo;
  GetDoctorAvailability(this.repo);
  Future<List<AvailabilityRule>> call(String doctorId) => repo.getDoctorAvailability(doctorId);
}

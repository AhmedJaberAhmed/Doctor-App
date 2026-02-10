

import 'Doctor.dart';
import 'home_repository.dart';

class GetDoctorDetails {
  final HomeRepository repo;
  GetDoctorDetails(this.repo);
  Future<Doctor> call(String doctorId) => repo.getDoctorDetails(doctorId);
}

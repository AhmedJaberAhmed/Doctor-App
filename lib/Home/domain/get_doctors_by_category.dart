

import 'Doctor.dart';
import 'home_repository.dart';

class GetDoctorsByCategory {
  final HomeRepository repo;
  GetDoctorsByCategory(this.repo);
  Future<List<Doctor>> call(String categoryId) => repo.getDoctorsByCategory(categoryId);
}

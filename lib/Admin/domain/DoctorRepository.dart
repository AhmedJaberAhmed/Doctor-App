import 'create_doctor_input.dart';
import 'doctor.dart';

abstract class DoctorRepository {
  Future<DoctorAdmin> createDoctor(CreateDoctorInput input);
}
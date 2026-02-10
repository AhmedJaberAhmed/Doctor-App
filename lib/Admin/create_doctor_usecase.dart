
import 'domain/DoctorRepository.dart';
import 'domain/create_doctor_input.dart';
import 'domain/doctor.dart';

class CreateDoctorUseCase {
  final DoctorRepository repo;

  const CreateDoctorUseCase(this.repo);

  Future<DoctorAdmin> call(CreateDoctorInput input) {
    return repo.createDoctor(input);
  }
}

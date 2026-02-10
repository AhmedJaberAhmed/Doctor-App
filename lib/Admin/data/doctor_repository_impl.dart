import '../domain/DoctorRemoteDataSource.dart';
import '../domain/DoctorRepository.dart';
import '../domain/create_doctor_input.dart';
import '../domain/doctor.dart';

class DoctorRepositoryImpl implements DoctorRepository {
  final DoctorRemoteDataSource remote;

  DoctorRepositoryImpl(this.remote);

  @override
  Future<DoctorAdmin> createDoctor(CreateDoctorInput input) async {
    // Step 1: upload photo (optional)
    String? photoPath;
    final tempId = DateTime.now().millisecondsSinceEpoch.toString();

    if (input.photoBytes != null &&
        input.photoBytes!.isNotEmpty &&
        input.photoFileExt != null &&
        input.photoFileExt!.isNotEmpty) {
      photoPath = await remote.uploadDoctorPhoto(
        doctorTempId: tempId,
        bytes: input.photoBytes!,
        ext: input.photoFileExt!,
      );
    }

    // Step 2: insert doctor
    final doctorDto = await remote.insertDoctor(
      fullName: input.fullName,
      title: input.title,
      bio: input.bio,

      phone: input.phone, // ✅ NEW

      consultationFeeCents: input.consultationFeeCents,
      currency: input.currency,
      clinicName: input.clinicName,
      clinicAddress: input.clinicAddress,
      city: input.city,
      photoPath: photoPath,
    );

    // Step 3: link categories
    await remote.setDoctorCategories(
      doctorId: doctorDto.id,
      categoryIds: input.categoryIds,
    );

    // Step 4: add availability
    await remote.addAvailability(
      doctorId: doctorDto.id,
      availability: input.availability,
    );

    return doctorDto.toEntity();
  }
}

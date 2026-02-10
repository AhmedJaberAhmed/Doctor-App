
import '../data/doctor_dto.dart';
import 'Availability.dart';

abstract class DoctorRemoteDataSource {
  Future<String?> uploadDoctorPhoto({
    required String doctorTempId, // used for folder naming
    required List<int> bytes,
    required String ext,
  });

  Future<DoctorDto> insertDoctor({
    required String fullName,
    String? title,
    String? bio,
    String? phone, // ✅ ADD THIS
    required int consultationFeeCents,
    required String currency,
    String? clinicName,
    String? clinicAddress,
    String? city,
    String? photoPath,
  });


  Future<void> setDoctorCategories({
    required String doctorId,
    required List<String> categoryIds,
  });

  Future<void> addAvailability({
    required String doctorId,
    required List<Availability> availability,
  });
}

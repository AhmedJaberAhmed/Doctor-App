import 'dart:math';
import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/Availability.dart';
import '../domain/DoctorRemoteDataSource.dart';
import 'doctor_dto.dart';

class DoctorRemoteDataSourceImpl implements DoctorRemoteDataSource {
  final SupabaseClient supabase;
  final String bucketName;

  DoctorRemoteDataSourceImpl({
    required this.supabase,
    this.bucketName = 'doctor-media',
  });

  @override
  Future<String?> uploadDoctorPhoto({
    required String doctorTempId,
    required List<int> bytes,
    required String ext,
  }) async {
    // Avoid collisions
    final rand = Random().nextInt(999999);
    final safeExt = ext.trim().isEmpty ? 'jpg' : ext.trim().toLowerCase();
    final path = 'doctors/$doctorTempId/photo_$rand.$safeExt';

    final Uint8List uint8Bytes = Uint8List.fromList(bytes);

    await supabase.storage.from(bucketName).uploadBinary(
      path,
      uint8Bytes,
      fileOptions: const FileOptions(upsert: false),
    );

    return path; // store this in doctors.photo_path
  }

  @override
  Future<DoctorDto> insertDoctor({
    required String fullName,
    String? title,
    String? phone, // ✅ add

    String? bio,
    required int consultationFeeCents,
    required String currency,
    String? clinicName,
    String? clinicAddress,
    String? city,
    String? photoPath,
  }) async {
    // No sign-in: do NOT require auth user id
    final data = await supabase
        .from('doctors')
        .insert({
      'created_by': null, // <--- important change
      'full_name': fullName,
      'title': title,
      'bio': bio,
      'phone': phone, // ✅ add

      'consultation_fee_cents': consultationFeeCents,
      'currency': currency,
      'clinic_name': clinicName,
      'clinic_address': clinicAddress,
      'city': city,
      'photo_path': photoPath,
      'is_active': true,
    })
        .select()
        .single();

    return DoctorDto.fromJson(data);
  }

  @override
  Future<void>  setDoctorCategories({
    required String doctorId,
    required List<String> categoryIds,
  }) async {
    if (categoryIds.isEmpty) return;

    final rows = categoryIds
        .map((catId) => {
      'doctor_id': doctorId,
      'category_id': catId,
    })
        .toList();

    await supabase.from('doctor_categories').insert(rows);
  }

  @override
  Future<void> addAvailability({
    required String doctorId,
    required List<Availability> availability,
  }) async {
    if (availability.isEmpty) return;

    final rows = availability
        .map((a) => {
      'doctor_id': doctorId,
      'day_of_week': a.dayOfWeek,
      'start_time': a.startTime,
      'end_time': a.endTime,
      'slot_minutes': a.slotMinutes,
      'is_active': true,
    })
        .toList();

    await supabase.from('doctor_availability').insert(rows);
  }
}

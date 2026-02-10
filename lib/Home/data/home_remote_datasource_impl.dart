import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/home_remote_datasource.dart';

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final SupabaseClient supabase;
  HomeRemoteDataSourceImpl({required this.supabase});

  @override
  Future<List<Map<String, dynamic>>> getCategories() async {
    final data = await supabase
        .from('categories')
        .select('id,name,icon')
        .order('name', ascending: true);
    return (data as List).cast<Map<String, dynamic>>();
  }

  @override
  Future<List<Map<String, dynamic>>> getDoctorsByCategory(String categoryId) async {
    // Join via doctor_categories
    final data = await supabase
        .from('doctor_categories')
        .select('doctor_id, doctors:doctors(id,full_name,title,clinic_name,city,photo_path,consultation_fee_cents,currency,rating_avg,rating_count,is_active)')
        .eq('category_id', categoryId);

    final rows = (data as List).cast<Map<String, dynamic>>();
    final doctors = <Map<String, dynamic>>[];

    for (final r in rows) {
      final d = r['doctors'];
      if (d != null && d is Map<String, dynamic>) {
        if ((d['is_active'] ?? true) == true) doctors.add(d);
      }
    }

    // Optional: sort by rating desc
    doctors.sort((a, b) => (b['rating_avg'] as num).compareTo(a['rating_avg'] as num));
    return doctors;
  }

  @override
  Future<Map<String, dynamic>> getDoctorDetails(String doctorId) async {
    final data = await supabase
        .from('doctors')
        .select('id,full_name,title,bio,phone,email,clinic_name,clinic_address,city,consultation_fee_cents,currency,photo_path,rating_avg,rating_count,is_active')
        .eq('id', doctorId)
        .single();
    return data as Map<String, dynamic>;
  }

  @override
  Future<List<Map<String, dynamic>>> getDoctorAvailability(String doctorId) async {
    final data = await supabase
        .from('doctor_availability')
        .select('id,doctor_id,day_of_week,start_time,end_time,slot_minutes,is_active')
        .eq('doctor_id', doctorId)
        .eq('is_active', true)
        .order('day_of_week', ascending: true);
    return (data as List).cast<Map<String, dynamic>>();
  }

  @override
  Future<void> bookAppointment({
    required String userId,
    required String doctorId,
    required DateTime startsAt,
    required DateTime endsAt,
    String? patientNote,
    required int feeCents,
    required String currency,
  }) async {
    // send ISO UTC to timestamptz
    await supabase.from('appointments').insert({
      'user_id': userId,
      'doctor_id': doctorId,
      'starts_at': startsAt.toUtc().toIso8601String(),
      'ends_at': endsAt.toUtc().toIso8601String(),
      'patient_note': patientNote,
      'fee_cents': feeCents,
      'currency': currency,
      // status default = pending_payment
    });
  }
  @override
  Future<List<Map<String, dynamic>>> getDoctorBookedAppointments({
    required String doctorId,
    required DateTime from,
    required DateTime to,
  }) async {
    final data = await supabase
        .from('appointments')
        .select('starts_at, ends_at, status')
        .eq('doctor_id', doctorId)
        .inFilter('status', ['pending_payment', 'confirmed'])
        .gte('starts_at', from.toUtc().toIso8601String())
        .lte('starts_at', to.toUtc().toIso8601String());

    return (data as List).cast<Map<String, dynamic>>();
  }


}

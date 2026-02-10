import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppointmentsRepository {
  final SupabaseClient supabase;
  AppointmentsRepository({SupabaseClient? supabaseClient})
      : supabase = supabaseClient ?? Supabase.instance.client;

  Future<String> createPendingAppointment({
    required String userId,
    required String doctorId,
    required DateTime startsAt,
    required DateTime endsAt,
    String? patientNote,
    required int feeCents,
    required String currency,
  }) async {
    try {
      final res = await supabase.from('appointments').insert({
        'user_id': userId,
        'doctor_id': doctorId,
        'starts_at': startsAt.toIso8601String(),
        'ends_at': endsAt.toIso8601String(),
        'status': 'pending_payment',
        'patient_note': patientNote,
        'fee_cents': feeCents,
        'currency': currency,
      }).select('id').single();

      return res['id'] as String;
    } on PostgrestException catch (e) {
      log('CREATE APPOINTMENT ERROR: ${e.message} code=${e.code} details=${e.details}');
      rethrow;
    }
  }

  Future<void> setAppointmentStatus({
    required String appointmentId,
    required String status, // confirmed/cancelled/completed/refunded...
  }) async {
    await supabase.from('appointments').update({
      'status': status,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', appointmentId);
  }

  Future<void> deleteAppointment(String appointmentId) async {
    await supabase.from('appointments').delete().eq('id', appointmentId);
  }
}

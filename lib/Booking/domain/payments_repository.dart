import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentsRepository {
  final SupabaseClient supabase;
  PaymentsRepository({SupabaseClient? supabaseClient})
      : supabase = supabaseClient ?? Supabase.instance.client;

  Future<void> createPayment({
    required String appointmentId,
    required String userId,
    required int amountCents,
    required String currency,
    String provider = 'paypal',
    String status = 'created',
  }) async {
    try {
      await supabase.from('payments').insert({
        'appointment_id': appointmentId,
        'user_id': userId,
        'provider': provider,
        'status': status,
        'amount_cents': amountCents,
        'currency': currency,
      });
    } on PostgrestException catch (e) {
      log('CREATE PAYMENT ERROR: ${e.message} code=${e.code} details=${e.details}');
      rethrow;
    }
  }

  Future<void> updatePayment({
    required String appointmentId,
    required String status,
    String? paypalOrderId,
    String? paypalCaptureId,
    Map<String, dynamic>? raw,
  }) async {
    await supabase.from('payments').update({
      'status': status,
      'paypal_order_id': paypalOrderId,
      'paypal_capture_id': paypalCaptureId,
      if (raw != null) 'raw': raw,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('appointment_id', appointmentId);
  }
}

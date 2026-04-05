import 'package:supabase_flutter/supabase_flutter.dart';

import 'Appointment.dart';
import 'AppointmentModel.dart';
import 'AppointmentRepositories.dart';

class AppointmentRepositoryImpl implements AppointmentRepository {
  final SupabaseClient _supabase;

  AppointmentRepositoryImpl(this._supabase);

  @override
  Future<List<Appointment>> getUserAppointments({
    AppointmentStatus? statusFilter,
  }) async {
    var query = _supabase.from('appointments').select(
        '*, doctors(full_name, title, photo_path, clinic_name, clinic_address), profiles(full_name, phone)');

    final response = await (statusFilter != null
            ? query.eq('status', _statusToString(statusFilter))
            : query)
        .order('starts_at', ascending: false);

    return (response as List)
        .map((json) => AppointmentModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> cancelAppointment(String appointmentId) async {
    await _supabase.from('appointments').update({
      'status': 'cancelled',
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', appointmentId);
  }

  String _statusToString(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pendingPayment:
        return 'pending_payment';
      case AppointmentStatus.confirmed:
        return 'confirmed';
      case AppointmentStatus.cancelled:
        return 'cancelled';
      case AppointmentStatus.completed:
        return 'completed';
      case AppointmentStatus.refunded:
        return 'refunded';
    }
  }
}

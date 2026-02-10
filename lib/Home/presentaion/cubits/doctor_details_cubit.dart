import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/AvailabilityRule.dart';
import '../../domain/booking_slot.dart';
import '../../domain/get_doctor_availability.dart';
import '../../domain/get_doctor_details.dart';
 import 'DoctorDetailsState.dart';
import 'get_doctor_booked_appointments.dart';

class DoctorDetailsCubit extends Cubit<DoctorDetailsState> {
  final GetDoctorDetails getDoctorDetails;
  final GetDoctorAvailability getDoctorAvailability;
  final GetDoctorBookedAppointments getDoctorBookedAppointments;

  DoctorDetailsCubit({
    required this.getDoctorDetails,
    required this.getDoctorAvailability,
    required this.getDoctorBookedAppointments,
  }) : super(const DoctorDetailsLoading());

  Future<void> load(String doctorId) async {
    emit(const DoctorDetailsLoading());
    try {
      final doctor = await getDoctorDetails(doctorId);
      final rules = await getDoctorAvailability(doctorId);

      final now = DateTime.now();
      final to = now.add(const Duration(days: 7));

      // ✅ fetch already booked ranges (from DB)
      final booked = await getDoctorBookedAppointments(
        doctorId: doctorId,
        from: now,
        to: to,
      );

      // generate all slots
      final slots = _generateSlots(
        rules,
        doctor.consultationFeeCents,
        doctor.currency,
      );

      // ✅ remove overlapping
      final filtered = slots.where((slot) {
        for (final r in booked) {
          final overlap =
              slot.startsAt.isBefore(r.end) && slot.endsAt.isAfter(r.start);
          if (overlap) return false;
        }
        return true;
      }).toList();

      emit(DoctorDetailsLoaded(doctor: doctor, slots: filtered));
    } catch (e) {
      emit(DoctorDetailsError(e.toString()));
    }
  }

  // Generate next 7 days slots from weekly rules
  List<BookingSlot> _generateSlots(
      List<AvailabilityRule> rules,
      int feeCents,
      String currency,
      ) {
    final now = DateTime.now();
    final endDate = now.add(const Duration(days: 7));

    final slots = <BookingSlot>[];

    for (var day = DateTime(now.year, now.month, now.day);
    day.isBefore(endDate);
    day = day.add(const Duration(days: 1))) {
      final dow = day.weekday % 7; // Sun=0..Sat=6
      final dayRules = rules.where((r) => r.dayOfWeek == dow).toList();

      for (final r in dayRules) {
        final start = _combine(day, r.startTime);
        final end = _combine(day, r.endTime);

        var cursor = start;
        while (cursor.add(Duration(minutes: r.slotMinutes)).isBefore(end) ||
            cursor
                .add(Duration(minutes: r.slotMinutes))
                .isAtSameMomentAs(end)) {
          final s = cursor;
          final e = cursor.add(Duration(minutes: r.slotMinutes));

          if (e.isAfter(now)) {
            slots.add(
              BookingSlot(
                startsAt: s,
                endsAt: e,
                feeCents: feeCents,
                currency: currency,
              ),
            );
          }
          cursor = e;
        }
      }
    }

    slots.sort((a, b) => a.startsAt.compareTo(b.startsAt));
    return slots.take(40).toList();
  }

  DateTime _combine(DateTime day, String hhmmss) {
    final p = hhmmss.split(':');
    final h = int.parse(p[0]);
    final m = int.parse(p[1]);
    return DateTime(day.year, day.month, day.day, h, m);
  }
}

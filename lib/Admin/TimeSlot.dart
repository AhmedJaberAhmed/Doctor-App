import 'domain/Availability.dart';

class TimeSlot {
  final DateTime start;
  final DateTime end;

  const TimeSlot({required this.start, required this.end});
}


class SlotGenerator {
  static int dayOfWeek0Sun(DateTime d) => d.weekday % 7; // Sun=0 ... Sat=6

  static List<TimeSlot> generateSlotsForDate({
    required DateTime dateLocal, // the day user selected (local)
    required List<Availability> weeklyAvailability,
  }) {
    final day = dayOfWeek0Sun(dateLocal);
    final dayAvail = weeklyAvailability.where((a) => a.dayOfWeek == day).toList();

    final slots = <TimeSlot>[];

    for (final a in dayAvail) {
      final startParts = a.startTime.split(':');
      final endParts = a.endTime.split(':');

      final start = DateTime(
        dateLocal.year,
        dateLocal.month,
        dateLocal.day,
        int.parse(startParts[0]),
        int.parse(startParts[1]),
      );

      final end = DateTime(
        dateLocal.year,
        dateLocal.month,
        dateLocal.day,
        int.parse(endParts[0]),
        int.parse(endParts[1]),
      );

      final step = Duration(minutes: a.slotMinutes);

      var cur = start;
      while (cur.add(step).isBefore(end) || cur.add(step).isAtSameMomentAs(end)) {
        slots.add(TimeSlot(start: cur, end: cur.add(step)));
        cur = cur.add(step);
      }
    }

    // sort
    slots.sort((x, y) => x.start.compareTo(y.start));
    return slots;
  }
}





class SlotFilter {
  /// bookedStarts are appointment.starts_at values (DateTime) for the same doctor and date
  static List<TimeSlot> removeBookedStarts({
    required List<TimeSlot> all,
    required Set<DateTime> bookedStarts,
  }) {
    return all.where((s) => !bookedStarts.contains(s.start)).toList();
  }
}

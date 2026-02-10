class Availability {
  final int dayOfWeek; // 0..6
  final String startTime; // "09:00:00"
  final String endTime;   // "17:00:00"
  final int slotMinutes;  // 10,15,20,30...

  const Availability({
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.slotMinutes,
  });
}

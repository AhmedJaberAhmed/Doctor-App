class AvailabilityRule {
  final String id;
  final String doctorId;
  final int dayOfWeek; // 0..6 (Sun..Sat)
  final String startTime; // "HH:mm:ss"
  final String endTime;   // "HH:mm:ss"
  final int slotMinutes;

  const AvailabilityRule({
    required this.id,
    required this.doctorId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.slotMinutes,
  });
}

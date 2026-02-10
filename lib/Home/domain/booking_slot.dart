class BookingSlot {
  final DateTime startsAt;
  final DateTime endsAt;
  final int feeCents;
  final String currency;

  const BookingSlot({
    required this.startsAt,
    required this.endsAt,
    required this.feeCents,
    required this.currency,
  });

  String get label {
    final h1 = startsAt.hour.toString().padLeft(2, '0');
    final m1 = startsAt.minute.toString().padLeft(2, '0');
    final h2 = endsAt.hour.toString().padLeft(2, '0');
    final m2 = endsAt.minute.toString().padLeft(2, '0');
    return "$h1:$m1 - $h2:$m2";
  }
}

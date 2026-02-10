
import '../domain/AvailabilityRule.dart';
import '../domain/Doctor.dart';
import '../domain/category.dart';
import '../domain/home_remote_datasource.dart';
import '../domain/home_repository.dart';
import '../presentaion/cubits/get_doctor_booked_appointments.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remote;
  HomeRepositoryImpl(this.remote);

  @override
  Future<List<Category>> getCategories() async {
    final rows = await remote.getCategories();
    return rows.map((e) {
      return Category(
        id: e['id'] as String,
        name: e['name'] as String,
        icon: e['icon'] as String?,
      );
    }).toList();
  }

  @override
  Future<List<Doctor>> getDoctorsByCategory(String categoryId) async {
    final rows = await remote.getDoctorsByCategory(categoryId);
    return rows.map(_doctorFromMap).toList();
  }

  @override
  Future<Doctor> getDoctorDetails(String doctorId) async {
    final map = await remote.getDoctorDetails(doctorId);
    return _doctorFromMap(map);
  }

  @override
  Future<List<AvailabilityRule>> getDoctorAvailability(String doctorId) async {
    final rows = await remote.getDoctorAvailability(doctorId);
    return rows.map((e) {
      return AvailabilityRule(
        id: e['id'] as String,
        doctorId: e['doctor_id'] as String,
        dayOfWeek: (e['day_of_week'] as num).toInt(),
        startTime: (e['start_time'] as String),
        endTime: (e['end_time'] as String),
        slotMinutes: (e['slot_minutes'] as num).toInt(),
      );
    }).toList();
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
  }) {
    return remote.bookAppointment(
      userId: userId,
      doctorId: doctorId,
      startsAt: startsAt,
      endsAt: endsAt,
      patientNote: patientNote,
      feeCents: feeCents,
      currency: currency,
    );
  }

  Doctor _doctorFromMap(Map<String, dynamic> d) {
    return Doctor(
      id: d['id'] as String,
      fullName: d['full_name'] as String,
      title: d['title'] as String?,
      bio: d['bio'] as String?,
      phone: d['phone'] as String?,
      email: d['email'] as String?,
      clinicName: d['clinic_name'] as String?,
      clinicAddress: d['clinic_address'] as String?,
      city: d['city'] as String?,
      consultationFeeCents: (d['consultation_fee_cents'] as num).toInt(),
      currency: (d['currency'] as String?) ?? 'USD',
      photoPath: d['photo_path'] as String?,
      ratingAvg: (d['rating_avg'] as num?)?.toDouble() ?? 0.0,
      ratingCount: (d['rating_count'] as num?)?.toInt() ?? 0,
    );
  }
  @override
  Future<List<Map<String, DateTime>>> getBookedRanges({
    required String doctorId,
    required DateTime from,
    required DateTime to,
  }) async {
    final rows = await remote.getDoctorBookedAppointments(
      doctorId: doctorId,
      from: from,
      to: to,
    );

    return rows.map((e) {
      final s = DateTime.parse(e['starts_at'] as String).toLocal();
      final en = DateTime.parse(e['ends_at'] as String).toLocal();
      return {'start': s, 'end': en};
    }).toList();
  }


  @override
  Future<List<BookedRange>> getDoctorBookedAppointments({
    required String doctorId,
    required DateTime from,
    required DateTime to,
  }) async {
    final rows = await remote.getDoctorBookedAppointments(
      doctorId: doctorId,
      from: from,
      to: to,
    );

    return rows.map((e) {
      final s = DateTime.parse(e['starts_at'] as String).toLocal();
      final en = DateTime.parse(e['ends_at'] as String).toLocal();
      return BookedRange(start: s, end: en);
    }).toList();
  }

}

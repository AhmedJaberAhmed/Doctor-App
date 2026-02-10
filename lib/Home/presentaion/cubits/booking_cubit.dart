import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/book_appointment.dart';
import 'booking_state.dart';

class BookingCubit extends Cubit<BookingState> {
  final BookAppointment bookAppointment;
  BookingCubit({required this.bookAppointment}) : super(const BookingIdle());

  Future<void> book({
    required String userId,
    required String doctorId,
    required DateTime startsAt,
    required DateTime endsAt,
    String? patientNote,
    required int feeCents,
    required String currency,
  }) async {
    emit(const BookingLoading());
    try {
      await bookAppointment(
        userId: userId,
        doctorId: doctorId,
        startsAt: startsAt,
        endsAt: endsAt,
        patientNote: patientNote,
        feeCents: feeCents,
        currency: currency,
      );
      emit(const BookingSuccess());
      emit(const BookingIdle());
    } catch (e) {
      emit(BookingError(e.toString()));
      emit(const BookingIdle());
    }
  }
}

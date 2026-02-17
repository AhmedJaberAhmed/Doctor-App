
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/Appointment.dart';
 import '../data/appointment UseCase.dart';

class BookingsCubit extends Cubit<BookingsState> {
  final GetUserAppointmentsUseCase _getAppointments;
  final CancelAppointmentUseCase _cancelAppointment;

  BookingsCubit({
    required GetUserAppointmentsUseCase getAppointments,
    required CancelAppointmentUseCase cancelAppointment,
  })  : _getAppointments = getAppointments,
        _cancelAppointment = cancelAppointment,
        super(const BookingsInitial());

  Future<void> loadAppointments({AppointmentStatus? statusFilter}) async {
    emit(const BookingsLoading());
    try {
      final appointments = await _getAppointments(statusFilter: statusFilter);
      emit(BookingsLoaded(appointments: appointments, activeFilter: statusFilter));
    } catch (e) {
      emit(BookingsError(e.toString()));
    }
  }

  Future<void> applyFilter(AppointmentStatus? status) async {
    final currentFilter = state is BookingsLoaded
        ? (state as BookingsLoaded).activeFilter
        : null;

     final newFilter = (status == currentFilter) ? null : status;
    await loadAppointments(statusFilter: newFilter);
  }

  Future<void> cancelAppointment(String appointmentId) async {
    if (state is! BookingsLoaded) return;
    final loaded = state as BookingsLoaded;

    emit(BookingsCancelling(
      appointments: loaded.appointments,
      activeFilter: loaded.activeFilter,
      cancellingId: appointmentId,
    ));

    try {
      await _cancelAppointment(appointmentId);
       await loadAppointments(statusFilter: loaded.activeFilter);
    } catch (e) {
       emit(loaded);
     }
  }

  Future<void> refresh() async {
    final filter = state is BookingsLoaded
        ? (state as BookingsLoaded).activeFilter
        : null;
    await loadAppointments(statusFilter: filter);
  }
}




abstract class BookingsState {
  const BookingsState();
}

class BookingsInitial extends BookingsState {
  const BookingsInitial();
}

class BookingsLoading extends BookingsState {
  const BookingsLoading();
}

class BookingsLoaded extends BookingsState {
  final List<Appointment> appointments;
  final AppointmentStatus? activeFilter;

  const BookingsLoaded({
    required this.appointments,
    this.activeFilter,
  });

  BookingsLoaded copyWith({
    List<Appointment>? appointments,
    AppointmentStatus? activeFilter,
    bool clearFilter = false,
  }) {
    return BookingsLoaded(
      appointments: appointments ?? this.appointments,
      activeFilter: clearFilter ? null : (activeFilter ?? this.activeFilter),
    );
  }
}

class BookingsError extends BookingsState {
  final String message;
  const BookingsError(this.message);
}

class BookingsCancelling extends BookingsLoaded {
  final String cancellingId;

  const BookingsCancelling({
    required super.appointments,
    super.activeFilter,
    required this.cancellingId,
  });
}
sealed class BookingState {
  const BookingState();
}

class BookingIdle extends BookingState {
  const BookingIdle();
}

class BookingLoading extends BookingState {
  const BookingLoading();
}

class BookingSuccess extends BookingState {
  const BookingSuccess();
}

class BookingError extends BookingState {
  final String message;
  const BookingError(this.message);
}

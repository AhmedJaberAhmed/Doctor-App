
import '../data/FavouriteDoctor.dart';

abstract class FavouritesState {}

class FavouritesInitial extends FavouritesState {}

class FavouritesLoading extends FavouritesState {}

class FavouritesLoaded extends FavouritesState {
  final List<FavouriteDoctor> favourites;
  final Set<String> favouriteDoctorIds;

  FavouritesLoaded({
    required this.favourites,
  }) : favouriteDoctorIds = favourites.map((f) => f.doctorId).toSet();

  bool isFavourite(String doctorId) => favouriteDoctorIds.contains(doctorId);
}

class FavouritesError extends FavouritesState {
  final String message;

  FavouritesError(this.message);
}
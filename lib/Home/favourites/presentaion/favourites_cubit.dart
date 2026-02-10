import 'package:flutter_bloc/flutter_bloc.dart';

import '../Favourites db.dart';
import '../data/FavouriteDoctor.dart';
import 'favourites_state.dart';

class FavouritesCubit extends Cubit<FavouritesState> {
  final FavouritesDbHelper _db = FavouritesDbHelper.instance;

  FavouritesCubit() : super(FavouritesInitial());

  Future<void> loadFavourites(String userId) async {
    try {
      emit(FavouritesLoading());

      final favouritesData = await _db.getFavourites(userId);
      final favourites = favouritesData
          .map((data) => FavouriteDoctor.fromMap(data))
          .toList();

      emit(FavouritesLoaded(favourites: favourites));
    } catch (e) {
      emit(FavouritesError('Failed to load favourites: ${e.toString()}'));
    }
  }

  Future<void> addFavourite({
    required String userId,
    required String doctorId,
    required String fullName,
    String? title,
    String? city,
    String? clinicName,
    String? photoPath,
    required double ratingAvg,
    required int ratingCount,
    required int consultationFeeCents,
    required String currency,
  }) async {
    try {
      await _db.addFavourite(
        userId: userId,
        doctorId: doctorId,
        fullName: fullName,
        title: title,
        city: city,
        clinicName: clinicName,
        photoPath: photoPath,
        ratingAvg: ratingAvg,
        ratingCount: ratingCount,
        consultationFeeCents: consultationFeeCents,
        currency: currency,
      );

      // Reload favourites
      await loadFavourites(userId);
    } catch (e) {
      emit(FavouritesError('Failed to add favourite: ${e.toString()}'));
    }
  }

  Future<void> removeFavourite({
    required String userId,
    required String doctorId,
  }) async {
    try {
      await _db.removeFavourite(userId: userId, doctorId: doctorId);

      // Reload favourites
      await loadFavourites(userId);
    } catch (e) {
      emit(FavouritesError('Failed to remove favourite: ${e.toString()}'));
    }
  }

  Future<void> clearAllFavourites(String userId) async {
    try {
      await _db.clearAllFavourites(userId);

      // Reload favourites
      await loadFavourites(userId);
    } catch (e) {
      emit(FavouritesError('Failed to clear favourites: ${e.toString()}'));
    }
  }

  Future<bool> checkIsFavourite({
    required String userId,
    required String doctorId,
  }) async {
    try {
      return await _db.isFavourite(userId: userId, doctorId: doctorId);
    } catch (e) {
      return false;
    }
  }
}
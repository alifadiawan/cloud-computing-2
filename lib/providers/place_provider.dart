import 'package:flutter/material.dart';

import '../models/place_model.dart';
import '../repositories/place_repository.dart';

class PlaceProvider extends ChangeNotifier {
  final PlaceRepository _placeRepository =
      PlaceRepository();

  /// =========================
  /// STATES
  /// =========================
  List<PlaceModel> _places = [];

  List<PlaceModel> get favoritePlaces =>
    _places
        .where(
          (place) =>
              place.isFavorite,
        )
        .toList();
        
  bool _isLoading = false;

  String _errorMessage = '';

  /// =========================
  /// GETTERS
  /// =========================
  List<PlaceModel> get places => _places;

  bool get isLoading => _isLoading;

  String get errorMessage => _errorMessage;

  /// =========================
  /// GET ALL PLACES
  /// =========================
  Future<void> fetchPlaces() async {
    try {
      _isLoading = true;
      _errorMessage = '';

      notifyListeners();

      _places =
          await _placeRepository.getPlaces();
    } catch (e) {
      _errorMessage =
          'Failed to fetch places';

      debugPrint(
        'PlaceProvider Error: $e',
      );
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  /// =========================
  /// SEARCH PLACES
  /// =========================
  Future<void> searchPlaces(
    String keyword,
  ) async {
    try {
      _isLoading = true;

      notifyListeners();

      _places = await _placeRepository
          .searchPlaces(keyword);
    } catch (e) {
      _errorMessage =
          'Failed to search places';

      debugPrint(
        'Search Error: $e',
      );
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  /// =========================
  /// FILTER CATEGORY
  /// =========================
  Future<void> getPlacesByCategory(
    String category,
  ) async {
    try {
      _isLoading = true;

      notifyListeners();

      _places = await _placeRepository
          .getPlacesByCategory(category);
    } catch (e) {
      _errorMessage =
          'Failed to filter category';

      debugPrint(
        'Category Error: $e',
      );
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  /// =========================
  /// REFRESH
  /// =========================
  Future<void> refreshPlaces() async {
  await fetchNearestPlaces();
  }

  /// =========================
  /// TOGGLE FAVORITE
  /// =========================
  void toggleFavorite(int id) {
    _places = _places.map((place) {
      if (place.id == id) {
        return place.copyWith(
          isFavorite:
              !place.isFavorite,
        );
      }

      return place;
    }).toList();

    notifyListeners();
  }

  Future<void> fetchNearestPlaces() async {
  try {
    _isLoading = true;

    notifyListeners();

    _places =
        await _placeRepository
            .getNearestPlaces();
  } catch (e) {
    _errorMessage =
        'Failed to get nearest places';

    debugPrint('$e');
  } finally {
    _isLoading = false;

    notifyListeners();
  }
}

}
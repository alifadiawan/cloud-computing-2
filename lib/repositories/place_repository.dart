import '../core/services/firebase_service.dart';
import '../models/place_model.dart';

class PlaceRepository {
  final FirebaseService _firebaseService;

  PlaceRepository({FirebaseService? firebaseService})
      : _firebaseService = firebaseService ?? FirebaseService();

  /// =========================
  /// GET ALL PLACES
  /// =========================
  Future<List<PlaceModel>> getPlaces() async {
    return await _firebaseService.getPlaces();
  }

  /// =========================
  /// GET PLACE DETAIL
  /// =========================
  Future<PlaceModel?> getPlaceById(
    int id,
  ) async {
    return await _firebaseService
        .getPlaceById(id);
  }

  /// =========================
  /// GET PLACES BY CATEGORY
  /// =========================
  Future<List<PlaceModel>>
      getPlacesByCategory(
    String category,
  ) async {
    return await _firebaseService
        .getPlacesByCategory(category);
  }

  /// =========================
  /// SEARCH PLACES
  /// =========================
  Future<List<PlaceModel>> searchPlaces(
    String keyword,
  ) async {
    return await _firebaseService
        .searchPlaces(keyword);
  }

  Future<List<PlaceModel>>
    getNearestPlaces() async {
  return await _firebaseService
      .getNearestPlaces();
}
}
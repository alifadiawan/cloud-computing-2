import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../../models/place_model.dart';
import 'location_service.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// =========================
  /// GET ALL PLACES
  /// =========================
  Future<List<PlaceModel>> getPlaces() async {
    try {
      final QuerySnapshot snapshot =
          await _firestore.collection('places').get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return PlaceModel.fromMap(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch places: $e');
    }
  }
  
  /// =========================
  /// GET PLACE DETAIL BY ID
  /// =========================
  Future<PlaceModel?> getPlaceById(int placeId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('places')
          .where('id', isEqualTo: placeId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return null;
      }

      final data =
          snapshot.docs.first.data() as Map<String, dynamic>;

      return PlaceModel.fromMap(data);
    } catch (e) {
      throw Exception(
        'Failed to fetch place detail: $e',
      );
    }
  }

  /// =========================
  /// GET PLACES BY CATEGORY
  /// =========================
  Future<List<PlaceModel>> getPlacesByCategory(
    String category,
  ) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('places')
          .where('category', isEqualTo: category)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;

        return PlaceModel.fromMap(data);
      }).toList();
    } catch (e) {
      throw Exception(
        'Failed to fetch category places: $e',
      );
    }
  }

  /// =========================
  /// SEARCH PLACE BY NAME
  /// =========================
  Future<List<PlaceModel>> searchPlaces(
    String keyword,
  ) async {
    try {
      final QuerySnapshot snapshot =
          await _firestore.collection('places').get();

      final places = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;

        return PlaceModel.fromMap(data);
      }).toList();

      return places.where((place) {
        return place.name
            .toLowerCase()
            .contains(keyword.toLowerCase());
      }).toList();
    } catch (e) {
      throw Exception(
        'Failed to search places: $e',
      );
    }
  }

  Future<List<PlaceModel>> getNearestPlaces() async {
    double userLat = -7.2575; // Surabaya default latitude
    double userLng = 112.7521; // Surabaya default longitude

    try {
      final position = await LocationService.getCurrentLocation();
      if (position != null) {
        userLat = position.latitude;
        userLng = position.longitude;
      }
    } catch (e) {
      print("Error getting location in getNearestPlaces: $e");
    }

    try {
      /// GET FIRESTORE DATA
      final QuerySnapshot snapshot =
          await _firestore.collection('places').get();

      final places = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;

        /// CALCULATE DISTANCE
        double distanceInMeters = Geolocator.distanceBetween(
          userLat,
          userLng,
          (data['latitude'] ?? 0).toDouble(),
          (data['longitude'] ?? 0).toDouble(),
        );

        /// METER -> KM
        double distanceKm = distanceInMeters / 1000;

        return PlaceModel.fromMap(
          data,
        ).copyWith(
          distance: distanceKm,
        );
      }).toList();

      /// SORT NEAREST
      places.sort(
        (a, b) => a.distance.compareTo(b.distance),
      );

      return places;
    } catch (e) {
      throw Exception(
        'Failed to get nearest places: $e',
      );
    }
  }

}
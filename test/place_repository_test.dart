import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_computing_2/models/place_model.dart';
import 'package:cloud_computing_2/repositories/place_repository.dart';
import 'package:cloud_computing_2/core/services/firebase_service.dart';

class MockFirebaseService implements FirebaseService {
  // Implement only the methods used by PlaceRepository
  @override
  Future<List<PlaceModel>> getPlaces() async {
    return [
      PlaceModel(
        id: 1,
        name: 'A',
        category: 'X',
        address: '',
        latitude: 0,
        longitude: 0,
        description: '',
        rating: 0,
        photoUrl: '',
      ),
    ];
  }

  @override
  Future<PlaceModel?> getPlaceById(int placeId) async {
    if (placeId == 1) {
      return PlaceModel(
        id: 1,
        name: 'A',
        category: 'X',
        address: '',
        latitude: 0,
        longitude: 0,
        description: '',
        rating: 0,
        photoUrl: '',
      );
    }
    return null;
  }

  @override
  Future<List<PlaceModel>> getPlacesByCategory(String category) async {
    return [
      PlaceModel(
        id: 2,
        name: 'B',
        category: category,
        address: '',
        latitude: 0,
        longitude: 0,
        description: '',
        rating: 0,
        photoUrl: '',
      ),
    ];
  }

  @override
  Future<List<PlaceModel>> searchPlaces(String keyword) async {
    return [
      PlaceModel(
        id: 3,
        name: 'SearchMatch',
        category: 'Y',
        address: '',
        latitude: 0,
        longitude: 0,
        description: '',
        rating: 0,
        photoUrl: '',
      ),
    ];
  }

  @override
  Future<List<PlaceModel>> getNearestPlaces() async {
    return [
      PlaceModel(
        id: 4,
        name: 'Near',
        category: 'Z',
        address: '',
        latitude: 0,
        longitude: 0,
        description: '',
        rating: 0,
        photoUrl: '',
      ),
    ];
  }
}

void main() {
  group('PlaceRepository (with MockFirebaseService)', () {
    late PlaceRepository repo;

    setUp(() {
      repo = PlaceRepository(firebaseService: MockFirebaseService());
    });

    test('getPlaces returns list', () async {
      final list = await repo.getPlaces();
      expect(list, isNotEmpty);
      expect(list.first.id, 1);
    });

    test('getPlaceById returns model for existing id', () async {
      final model = await repo.getPlaceById(1);
      expect(model, isNotNull);
      expect(model!.id, 1);
    });

    test('getPlacesByCategory filters by category', () async {
      final list = await repo.getPlacesByCategory('categoryX');
      expect(list.first.category, 'categoryX');
    });

    test('searchPlaces returns matches', () async {
      final list = await repo.searchPlaces('something');
      expect(list.first.name, 'SearchMatch');
    });

    test('getNearestPlaces returns nearest list', () async {
      final list = await repo.getNearestPlaces();
      expect(list.first.name, 'Near');
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_computing_2/models/place_model.dart';
import 'package:cloud_computing_2/providers/place_provider.dart';
import 'package:cloud_computing_2/repositories/place_repository.dart';

class MockPlaceRepository implements PlaceRepository {
  @override
  Future<List<PlaceModel>> getPlaces() async {
    return [
      PlaceModel(
        id: 1,
        name: 'A',
        category: 'C',
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
  Future<PlaceModel?> getPlaceById(int id) async {
    return PlaceModel(
      id: id,
      name: 'A',
      category: 'C',
      address: '',
      latitude: 0,
      longitude: 0,
      description: '',
      rating: 0,
      photoUrl: '',
    );
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
        name: 'Search',
        category: 'C',
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
        category: 'C',
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
  group('PlaceProvider (with MockPlaceRepository)', () {
    late PlaceProvider provider;

    setUp(() {
      provider = PlaceProvider(placeRepository: MockPlaceRepository());
    });

    test('fetchPlaces updates state and places', () async {
      await provider.fetchPlaces();
      expect(provider.places, isNotEmpty);
      expect(provider.isLoading, false);
      expect(provider.errorMessage, '');
    });

    test('searchPlaces updates places', () async {
      await provider.searchPlaces('x');
      expect(provider.places.first.name, 'Search');
    });

    test('getPlacesByCategory updates places', () async {
      await provider.getPlacesByCategory('cat');
      expect(provider.places.first.category, 'cat');
    });

    test('toggleFavorite flips favorite status and favoritePlaces getter', () async {
      // set initial list
      provider = PlaceProvider(placeRepository: MockPlaceRepository());
      await provider.fetchPlaces();
      final id = provider.places.first.id;

      provider.toggleFavorite(id);
      expect(provider.places.first.isFavorite, true);
      expect(provider.favoritePlaces.length, 1);

      provider.toggleFavorite(id);
      expect(provider.places.first.isFavorite, false);
      expect(provider.favoritePlaces.length, 0);
    });

    test('fetchNearestPlaces sets places', () async {
      await provider.fetchNearestPlaces();
      expect(provider.places.first.name, 'Near');
    });
  });
}

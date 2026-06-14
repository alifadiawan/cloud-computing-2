import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_computing_2/models/place_model.dart';

void main() {
  group('PlaceModel', () {
    test('fromMap and toMap roundtrip', () {
      final map = {
        'id': 1,
        'name': 'REJEKI MOTOR 1',
        'category': 'Bengkel',
        'address': 'Jl. Mawar',
        'latitude': 1.0,
        'longitude': 2.0,
        'description': 'Desc',
        'rating': 4.5,
        'photo_url': 'http://photo',
        'is_favorite': true,
        'distance': 1.2,
      };

      final model = PlaceModel.fromMap(map);

      expect(model.id, 1);
      expect(model.name, 'REJEKI MOTOR 1');
      expect(model.isFavorite, true);

      final back = model.toMap();
      expect(back['id'], 1);
      expect(back['photo_url'], 'http://photo');
      expect(back['is_favorite'], true);
    });

    test('copyWith keeps and overrides fields', () {
      final model = PlaceModel(
        id: 2,
        name: 'A',
        category: 'Cat',
        address: 'Addr',
        latitude: 0,
        longitude: 0,
        description: '',
        rating: 0,
        photoUrl: '',
      );

      final copy = model.copyWith(name: 'B', isFavorite: true);
      expect(copy.id, 2);
      expect(copy.name, 'B');
      expect(copy.isFavorite, true);
    });
  });
}

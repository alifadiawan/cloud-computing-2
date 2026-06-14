import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_computing_2/core/services/firebase_service.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late FirebaseService firebaseService;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    firebaseService = FirebaseService(firestore: fakeFirestore);
  });

  test('FirebaseService.getPlaces mengembalikan semua tempat yang tersedia', () async {
    await fakeFirestore.collection('places').add({
      'id': 1,
      'name': 'Pantai Kenjeran',
      'category': 'pantai',
      'address': 'Surabaya Timur',
      'latitude': -7.2427,
      'longitude': 112.7801,
      'description': 'Pantai populer di Surabaya',
      'rating': 4.5,
      'photo_url': 'https://example.com/kenjeran.jpg',
      'is_favorite': false,
    });

    await fakeFirestore.collection('places').add({
      'id': 2,
      'name': 'Kebun Raya Purwodadi',
      'category': 'alam',
      'address': 'Pasuruan',
      'latitude': -7.2163,
      'longitude': 112.0049,
      'description': 'Kebun botani luas',
      'rating': 4.2,
      'photo_url': 'https://example.com/purwodadi.jpg',
      'is_favorite': false,
    });

    final places = await firebaseService.getPlaces();

    expect(places, hasLength(2));
    expect(places.map((place) => place.id), containsAll(<int>[1, 2]));
  });

  test('FirebaseService.getPlaceById mengembalikan detail tempat yang benar', () async {
    await fakeFirestore.collection('places').add({
      'id': 10,
      'name': 'Taman Bungkul',
      'category': 'taman',
      'address': 'Surabaya',
      'latitude': -7.2800,
      'longitude': 112.7400,
      'description': 'Taman kota yang ramah keluarga',
      'rating': 4.0,
      'photo_url': 'https://example.com/bungkul.jpg',
      'is_favorite': false,
    });

    final place = await firebaseService.getPlaceById(10);

    expect(place, isNotNull);
    expect(place?.id, equals(10));
    expect(place?.name, equals('Taman Bungkul'));
  });

  test('FirebaseService.searchPlaces menyaring nama tempat dengan keyword', () async {
    await fakeFirestore.collection('places').add({
      'id': 11,
      'name': 'Museum Surabaya',
      'category': 'budaya',
      'address': 'Surabaya Pusat',
      'latitude': -7.2575,
      'longitude': 112.7521,
      'description': 'Museum sejarah kota',
      'rating': 4.3,
      'photo_url': 'https://example.com/museum.jpg',
      'is_favorite': false,
    });

    await fakeFirestore.collection('places').add({
      'id': 12,
      'name': 'Pantai Ria',
      'category': 'pantai',
      'address': 'Surabaya',
      'latitude': -7.2510,
      'longitude': 112.7900,
      'description': 'Pantai populer',
      'rating': 4.0,
      'photo_url': 'https://example.com/pantia.jpg',
      'is_favorite': false,
    });

    final results = await firebaseService.searchPlaces('museum');

    expect(results, hasLength(1));
    expect(results.first.name.toLowerCase(), contains('museum'));
  });
}
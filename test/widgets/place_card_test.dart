import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_computing_2/widgets/place_card.dart';
import 'package:cloud_computing_2/models/place_model.dart';

void main() {
  testWidgets('PlaceCard displays basic info and calls favorite callback',
      (WidgetTester tester) async {
    final place = PlaceModel(
      id: 10,
      name: 'REJEKI MOTOR 1',
      category: 'Bengkel Sepeda Motor',
      address: 'Jl. Mawar 1',
      latitude: 0,
      longitude: 0,
      description: 'desc',
      rating: 4.2,
      photoUrl: '',
      isFavorite: false,
      distance: 2.5,
    );

    var favoriteTapped = false;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: PlaceCard(
          place: place,
          onFavoriteTap: () {
            favoriteTapped = true;
          },
        ),
      ),
    ));

    expect(find.text('REJEKI MOTOR 1'), findsOneWidget);
    expect(find.text('Bengkel Sepeda Motor'), findsOneWidget);
    expect(find.text('2.5 km'), findsOneWidget);
    expect(find.text('4.2'), findsOneWidget);

    // favorite icon exists
    expect(find.byIcon(Icons.favorite_border), findsOneWidget);

    await tester.tap(find.byIcon(Icons.favorite_border));
    expect(favoriteTapped, true);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_computing_2/screens/detail/place_detail_screen.dart';
import 'package:cloud_computing_2/models/place_model.dart';

void main() {
  testWidgets('PlaceDetailScreen shows name and Open Route button',
      (WidgetTester tester) async {
    final place = PlaceModel(
      id: 99,
      name: 'RIZKY MOTOR',
      category: 'Bengkel',
      address: 'Jl. Sudirman',
      latitude: 0,
      longitude: 0,
      description: 'desc',
      rating: 4.0,
      photoUrl: '',
    );

    await tester.pumpWidget(MaterialApp(
      home: PlaceDetailScreen(place: place),
    ));

    expect(find.text('RIZKY MOTOR'), findsWidgets);
    expect(find.text('Open Route'), findsOneWidget);

    // Button exists (interaction omitted because it navigates)
  });
}

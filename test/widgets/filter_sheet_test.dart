import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_computing_2/widgets/filter_sheet.dart';

void main() {
  testWidgets('FilterSheet calls onSelected when option tapped',
      (WidgetTester tester) async {
    String? selected;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(builder: (context) {
          return ElevatedButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (_) => FilterSheet(
                  selectedFilter: null,
                  onSelected: (v) => selected = v,
                ),
              );
            },
            child: Text('open'),
          );
        }),
      ),
    ));

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Urutkan bengkel'), findsOneWidget);

    // Tap the first option label
    await tester.tap(find.text('Jarak Terdekat'));
    await tester.pumpAndSettle();

    expect(selected, 'Terdekat');
  });
}

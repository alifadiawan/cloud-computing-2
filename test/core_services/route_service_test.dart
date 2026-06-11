import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_computing_2/core/services/route_service.dart';

void main() {
  test('RouteService.getRouteCoordinates returns correct LatLng list', () async {
    final responseBody = jsonEncode({
      'features': [
        {
          'geometry': {
            'coordinates': [
              [112.75, -7.25],
              [112.76, -7.26],
            ],
          },
        }
      ]
    });

    final client = MockClient((request) async {
      return http.Response(responseBody, 200);
    });

    final points = await RouteService.getRouteCoordinates(
      start: LatLng(-7.25, 112.75),
      end: LatLng(-7.26, 112.76),
      client: client,
    );

    expect(points.length, 2);
    expect(points[0].latitude, -7.25);
    expect(points[0].longitude, 112.75);
    expect(points[1].latitude, -7.26);
    expect(points[1].longitude, 112.76);
  });
}

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class RouteService {
  static const String apiKey =
      'eyJvcmciOiI1YjNjZTM1OTc4NTExMTAwMDFjZjYyNDgiLCJpZCI6IjkzYzU2MzRjOGU5MzQ3MGU4ZWE4YWM4ZjlhYTE3YWZmIiwiaCI6Im11cm11cjY0In0=';

  /// =========================
  /// GET ROUTE
  /// =========================
  static Future<List<LatLng>>
      getRouteCoordinates({
    required LatLng start,
    required LatLng end,
    http.Client? client,
  }) async {
    final url = Uri.parse(
      'https://api.openrouteservice.org/v2/directions/driving-car?api_key=$apiKey&start=${start.longitude},${start.latitude}&end=${end.longitude},${end.latitude}',
    );

    final http.Client httpClient = client ?? http.Client();
    final response = await httpClient.get(url);

    if (response.statusCode == 200) {
      final data =
          jsonDecode(response.body);

      final coordinates = data['features']
              [0]['geometry']['coordinates']
          as List;

      return coordinates.map((coordinate) {
        return LatLng(
          coordinate[1],
          coordinate[0],
        );
      }).toList();
    } else {
      throw Exception(
        'Failed to load route',
      );
    }
  }
}
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';
import 'package:cloud_computing_2/core/services/location_service.dart';

class FakeGeolocatorPlatform extends GeolocatorPlatform {
  FakeGeolocatorPlatform({
    required this.serviceEnabled,
    required this.checkedPermission,
    required this.requestedPermission,
    required this.position,
  });

  final bool serviceEnabled;
  final LocationPermission checkedPermission;
  final LocationPermission requestedPermission;
  final Position? position;

  @override
  Future<bool> isLocationServiceEnabled() async => serviceEnabled;

  @override
  Future<LocationPermission> checkPermission() async => checkedPermission;

  @override
  Future<LocationPermission> requestPermission() async => requestedPermission;

  @override
  Future<Position> getCurrentPosition({LocationSettings? locationSettings}) async {
    if (position == null) {
      throw StateError('No position available');
    }
    return position!;
  }
}

void main() {
  late GeolocatorPlatform originalGeolocatorPlatform;

  setUpAll(() {
    originalGeolocatorPlatform = GeolocatorPlatform.instance;
  });

  tearDownAll(() {
    GeolocatorPlatform.instance = originalGeolocatorPlatform;
  });

  test('LocationService.getCurrentLocation returns null when GPS dimatikan', () async {
    GeolocatorPlatform.instance = FakeGeolocatorPlatform(
      serviceEnabled: false,
      checkedPermission: LocationPermission.denied,
      requestedPermission: LocationPermission.denied,
      position: null,
    );

    final result = await LocationService.getCurrentLocation();

    expect(result, isNull);
  });

  test('LocationService.getCurrentLocation returns null saat izin ditolak forever', () async {
    GeolocatorPlatform.instance = FakeGeolocatorPlatform(
      serviceEnabled: true,
      checkedPermission: LocationPermission.deniedForever,
      requestedPermission: LocationPermission.deniedForever,
      position: null,
    );

    final result = await LocationService.getCurrentLocation();

    expect(result, isNull);
  });

  test('LocationService.getCurrentLocation returns posisi saat izin diberikan', () async {
    final mockedPosition = Position(
      latitude: -7.2575,
      longitude: 112.7521,
      timestamp: DateTime.now(),
      accuracy: 1.0,
      altitude: 0.0,
      altitudeAccuracy: 0.0,
      heading: 0.0,
      headingAccuracy: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
    );

    GeolocatorPlatform.instance = FakeGeolocatorPlatform(
      serviceEnabled: true,
      checkedPermission: LocationPermission.always,
      requestedPermission: LocationPermission.always,
      position: mockedPosition,
    );

    final result = await LocationService.getCurrentLocation();

    expect(result, equals(mockedPosition));
  });
}

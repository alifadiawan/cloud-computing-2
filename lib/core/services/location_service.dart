import 'package:geolocator/geolocator.dart';

class LocationService {
  /// =========================
  /// GET CURRENT LOCATION
  /// =========================
  static Future<Position?>
      getCurrentLocation() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      /// CHECK GPS SERVICE
      serviceEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        return null;
      }

      /// CHECK PERMISSION
      permission =
          await Geolocator.checkPermission();

      if (permission ==
          LocationPermission.denied) {
        permission =
            await Geolocator.requestPermission();

        if (permission ==
            LocationPermission.denied) {
          return null;
        }
      }

      if (permission ==
          LocationPermission.deniedForever) {
        return null;
      }

      /// GET CURRENT POSITION
      return await Geolocator.getCurrentPosition(
        desiredAccuracy:
            LocationAccuracy.high,
      );
    } catch (e) {
      print("Error getting location: $e");
      return null;
    }
  }
}
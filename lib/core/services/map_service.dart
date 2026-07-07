import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

typedef LaunchFunction = Future<bool> Function(Uri url, {LaunchMode? mode});

class MapService {
  /// =========================
  /// OPEN GOOGLE MAPS
  /// =========================
  static Future<void> openGoogleMaps(
    double latitude,
    double longitude, {
    LaunchFunction? launcher,
  }) async {
    final Uri url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude',
    );

    final LaunchFunction launchFunc = launcher ??
        (Uri uri, {LaunchMode? mode}) =>
            launchUrl(uri, mode: mode ?? LaunchMode.platformDefault);

    try {
      if (kIsWeb) {
        /// WEB
        await launchFunc(url);
      } else {
        /// ANDROID / IOS
        await launchFunc(
          url,
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      debugPrint(
        'Failed to open map: $e',
      );
    }
  }
}
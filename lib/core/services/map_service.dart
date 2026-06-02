import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MapService {
  /// =========================
  /// OPEN GOOGLE MAPS
  /// =========================
  static Future<void> openGoogleMaps(
    double latitude,
    double longitude,
  ) async {
    final Uri url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude',
    );

    try {
      if (kIsWeb) {
        /// WEB
        await launchUrl(url);
      } else {
        /// ANDROID / IOS
        await launchUrl(
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
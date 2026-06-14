import 'package:flutter_test/flutter_test.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_computing_2/core/services/map_service.dart';

void main() {
  test('MapService.openGoogleMaps uses launcher function with external mode', () async {
    late Uri capturedUri;
    LaunchMode? capturedMode;

    // Perbaikan: Menggunakan deklarasi fungsi standar daripada variabel
    Future<bool> mockLauncher(Uri url, {LaunchMode? mode}) async {
      capturedUri = url;
      capturedMode = mode;
      return true;
    }

    await MapService.openGoogleMaps(
      -7.25,
      112.75,
      launcher: mockLauncher,
    );

    expect(
      capturedUri.toString(),
      'https://www.google.com/maps/dir/?api=1&destination=-7.25,112.75',
    );
    expect(capturedMode, LaunchMode.externalApplication);
  });
}
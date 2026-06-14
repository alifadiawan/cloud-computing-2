import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../core/services/location_service.dart';
import '../../core/services/route_service.dart';
import '../../models/place_model.dart';
import '../../providers/place_provider.dart';
import '../detail/place_detail_screen.dart';

class MapScreen extends StatefulWidget {
  final PlaceModel? destinationPlace;

  const MapScreen({
    super.key,
    this.destinationPlace,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  Position? currentPosition;
  bool isLoadingLocation = true;

  // ---> TEMA 2: Trust & Professional (Navy & Steel) <---
  final Color _primaryColor = const Color(0xFF1A365D); // Navy Blue
  final Color _secondaryColor = const Color(0xFF2B6CB0); // Bright Blue (cocok untuk rute)
  final Color _titleColor = const Color(0xFF1A365D); // Navy Blue

  /// =========================
  /// REAL ROUTE POINTS
  /// =========================
  List<LatLng> routePoints = [];

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      await context.read<PlaceProvider>().fetchPlaces();
      await initializeMap();
    });
  }

  /// =========================
  /// INITIALIZE MAP
  /// =========================
  Future<void> initializeMap() async {
    final position = await LocationService.getCurrentLocation();

    if (position != null) {
      currentPosition = position;

      /// GET REAL ROUTE
      if (widget.destinationPlace != null) {
        routePoints = await RouteService.getRouteCoordinates(
          start: LatLng(
            position.latitude,
            position.longitude,
          ),
          end: LatLng(
            widget.destinationPlace!.latitude,
            widget.destinationPlace!.longitude,
          ),
        );
      }

      setState(() {
        isLoadingLocation = false;
      });

      /// MOVE CAMERA
      if (widget.destinationPlace != null) {
        _mapController.move(
          LatLng(
            widget.destinationPlace!.latitude,
            widget.destinationPlace!.longitude,
          ),
          14,
        );
      } else {
        _mapController.move(
          LatLng(
            position.latitude,
            position.longitude,
          ),
          14,
        );
      }
    } else {
      setState(() {
        isLoadingLocation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PlaceProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 4, 
        shadowColor: _primaryColor.withValues(alpha: 0.15),
        iconTheme: IconThemeData(color: _titleColor),
        title: Text(
          widget.destinationPlace != null
              ? widget.destinationPlace!.name
              : 'Peta Bengkel',
          style: TextStyle(
            color: _titleColor,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: provider.isLoading || isLoadingLocation
          ? Center(
              child: CircularProgressIndicator(color: _primaryColor),
            )
          : FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: currentPosition != null
                    ? LatLng(
                        currentPosition!.latitude,
                        currentPosition!.longitude,
                      )
                    : const LatLng(
                        -7.2575,
                        112.7521,
                      ),
                initialZoom: 14,
              ),
              children: [
                /// =========================
                /// MAP TILE
                /// =========================
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.cloud_computing_2',
                ),

                /// =========================
                /// ROUTE LINE (Bright Blue)
                /// =========================
                if (routePoints.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: routePoints,
                        strokeWidth: 6,
                        color: _secondaryColor, // Warna Bright Blue agar kontras di peta
                      ),
                    ],
                  ),

                /// =========================
                /// MARKERS
                /// =========================
                MarkerLayer(
                  markers: [
                    /// =========================
                    /// DESTINATION ONLY
                    /// =========================
                    if (widget.destinationPlace != null)
                      Marker(
                        point: LatLng(
                          widget.destinationPlace!.latitude,
                          widget.destinationPlace!.longitude,
                        ),
                        width: 120,
                        height: 100,
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _primaryColor, // Navy Blue
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                widget.destinationPlace!.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Icon(
                              Icons.location_on_rounded, // Penanda lokasi profesional
                              color: _primaryColor,
                              size: 45,
                            ),
                          ],
                        ),
                      ),

                    /// =========================
                    /// ALL MARKERS (Map Umum)
                    /// =========================
                    if (widget.destinationPlace == null)
                      ...provider.places.map(
                        (place) {
                          return Marker(
                            point: LatLng(
                              place.latitude,
                              place.longitude,
                            ),
                            width: 90,
                            height: 90,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PlaceDetailScreen(place: place),
                                  ),
                                );
                              },
                              child: Icon(
                                Icons.build_circle_rounded, 
                                color: _primaryColor, // Navy Blue
                                size: 42,
                              ),
                            ),
                          );
                        },
                      ),

                    /// =========================
                    /// USER MARKER 
                    /// =========================
                    if (currentPosition != null)
                      Marker(
                        point: LatLng(
                          currentPosition!.latitude,
                          currentPosition!.longitude,
                        ),
                        width: 80,
                        height: 80,
                        child: Column(
                          children: [
                            Icon(
                              Icons.person_pin_circle_rounded, // Ikon user elegan
                              color: _secondaryColor, // Bright Blue
                              size: 40,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Kamu',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _titleColor,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
          ),
      ); 
  }
}
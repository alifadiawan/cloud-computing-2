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
  State<MapScreen> createState() =>
      _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController =
      MapController();

  Position? currentPosition;

  bool isLoadingLocation = true;

  /// =========================
  /// REAL ROUTE POINTS
  /// =========================
  List<LatLng> routePoints = [];

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      await context
          .read<PlaceProvider>()
          .fetchPlaces();

      await initializeMap();
    });
  }

  /// =========================
  /// INITIALIZE MAP
  /// =========================
  Future<void> initializeMap() async {
    final position =
        await LocationService.getCurrentLocation();

    if (position != null) {
      currentPosition = position;

      /// GET REAL ROUTE
      if (widget.destinationPlace != null) {
        routePoints =
            await RouteService
                .getRouteCoordinates(
          start: LatLng(
            position.latitude,
            position.longitude,
          ),

          end: LatLng(
            widget.destinationPlace!
                .latitude,
            widget.destinationPlace!
                .longitude,
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
            widget.destinationPlace!
                .latitude,
            widget.destinationPlace!
                .longitude,
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
    final provider =
        Provider.of<PlaceProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.destinationPlace != null
              ? widget.destinationPlace!.name
              : 'Bengkel Map',
        ),
        centerTitle: true,
      ),

      body: provider.isLoading ||
              isLoadingLocation
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : FlutterMap(
              mapController: _mapController,

              options: MapOptions(
                initialCenter:
                    currentPosition != null
                        ? LatLng(
                            currentPosition!
                                .latitude,
                            currentPosition!
                                .longitude,
                          )
                        : LatLng(
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
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',

                  userAgentPackageName:
                      'com.example.cloud_computing_2',
                ),

                /// =========================
                /// ROUTE LINE
                /// =========================
                if (routePoints.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: routePoints,

                        strokeWidth: 6,

                        color: Colors.blue,
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
                    if (widget.destinationPlace !=
                        null)
                      Marker(
                        point: LatLng(
                          widget.destinationPlace!
                              .latitude,
                          widget.destinationPlace!
                              .longitude,
                        ),

                        width: 100,
                        height: 100,

                        child: Column(
                          children: [
                            Container(
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),

                              decoration:
                                  BoxDecoration(
                                color: Colors.blue,

                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  10,
                                ),
                              ),

                              child: Text(
                                widget
                                    .destinationPlace!
                                    .name,

                                maxLines: 1,

                                overflow:
                                    TextOverflow
                                        .ellipsis,

                                style:
                                    const TextStyle(
                                  color:
                                      Colors.white,

                                  fontWeight:
                                      FontWeight
                                          .bold,

                                  fontSize: 11,
                                ),
                              ),
                            ),

                            const SizedBox(
                              height: 4,
                            ),

                            const Icon(
                              Icons.location_on,
                              color: Colors.blue,
                              size: 45,
                            ),
                          ],
                        ),
                      ),

                    /// =========================
                    /// ALL MARKERS
                    /// =========================
                    if (widget.destinationPlace ==
                        null)
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
                                    builder: (_) =>
                                        PlaceDetailScreen(
                                      place: place,
                                    ),
                                  ),
                                );
                              },

                              child: const Icon(
                                Icons.location_on,
                                color: Colors.red,
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
                          currentPosition!
                              .latitude,
                          currentPosition!
                              .longitude,
                        ),

                        width: 80,
                        height: 80,

                        child: const Column(
                          children: [
                            Icon(
                              Icons.my_location,
                              color: Colors.blue,
                              size: 40,
                            ),

                            Text(
                              'You',
                              style: TextStyle(
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),

      /// =========================
      /// MY LOCATION BUTTON
      /// =========================
      floatingActionButton:
          FloatingActionButton(
        onPressed: () async {
          await initializeMap();
        },

        child: const Icon(
          Icons.my_location,
        ),
      ),
    );
  }
}
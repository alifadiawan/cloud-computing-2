import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../core/services/location_service.dart';
import '../../core/services/route_service.dart';
import '../../models/place_model.dart';
import '../../providers/place_provider.dart';

class MapScreen extends StatefulWidget {
  final PlaceModel? destinationPlace;

  const MapScreen({super.key, this.destinationPlace});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const Color _navy = Color(0xFF102A43);
  static const Color _blue = Color(0xFF2B6CB0);
  static const Color _sky = Color(0xFFEBF8FF);
  static const Color _surface = Color(0xFFF4F7FB);

  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  StreamSubscription<Position>? _positionSubscription;
  Position? _currentPosition;
  LatLng? _lastRouteOrigin;
  DateTime? _lastRouteUpdate;
  PlaceModel? _selectedPlace;
  List<LatLng> _routePoints = [];
  final List<LatLng> _travelledPoints = [];
  String _searchQuery = '';
  String? _locationMessage;
  bool _isLoadingLocation = true;
  bool _isLoadingRoute = false;
  bool _isRefreshingRoute = false;
  bool _isNavigationPaused = false;
  bool _followUser = true;
  bool _hasArrived = false;
  bool _isOffRoute = false;
  double? _initialRouteDistance;
  double _currentRouteDistance = 0;
  double _currentZoom = 14;

  bool get _isRouteMode => widget.destinationPlace != null;

  double? get _remainingDistance {
    if (!_isRouteMode || _currentPosition == null) return null;
    return Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      widget.destinationPlace!.latitude,
      widget.destinationPlace!.longitude,
    );
  }

  String _formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.round()} m';
    }
    return '${(distanceInMeters / 1000).toStringAsFixed(1)} km';
  }

  String get _estimatedTime {
    if (_hasArrived) return 'Tiba';
    final distance = _currentRouteDistance > 0
        ? _currentRouteDistance
        : (_remainingDistance ?? 0);
    if (distance <= 35) return 'Tiba';

    final gpsSpeed = _currentPosition?.speed ?? 0;
    final effectiveSpeed = gpsSpeed > 1.4 ? gpsSpeed : 6.9;
    final minutes = (distance / effectiveSpeed / 60).ceil();

    if (minutes < 60) return '$minutes mnt';
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    return remainingMinutes == 0
        ? '$hours jam'
        : '$hours j ${remainingMinutes}m';
  }

  String get _speedLabel {
    final rawSpeed = _currentPosition?.speed ?? 0;
    final speed = (rawSpeed.isFinite ? math.max(rawSpeed, 0) : 0) * 3.6;
    return '${speed.round()} km/j';
  }

  double get _navigationProgress {
    final initial = _initialRouteDistance;
    if (initial == null || initial <= 0) return 0;
    return (1 - (_currentRouteDistance / initial)).clamp(0.0, 1.0);
  }

  @override
  void initState() {
    super.initState();
    _selectedPlace = widget.destinationPlace;
    final provider = context.read<PlaceProvider>();

    Future.microtask(() async {
      if (!_isRouteMode) {
        await provider.fetchPlaces();
      }
      if (!mounted) return;
      await _initializeMap();
    });
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _initializeMap() async {
    if (mounted) {
      setState(() {
        _isLoadingLocation = true;
        _locationMessage = null;
      });
    }

    try {
      final position = await LocationService.getCurrentLocation();
      if (!mounted) return;

      if (position == null) {
        setState(() {
          _isLoadingLocation = false;
          _locationMessage =
              'Lokasi belum tersedia. Peta ditampilkan dari area Surabaya.';
        });
        return;
      }

      _currentPosition = position;

      if (_isRouteMode) {
        setState(() => _isLoadingRoute = true);
        await _refreshRoute(position, force: true);
      }

      if (!mounted) return;
      setState(() {
        _isLoadingLocation = false;
        _isLoadingRoute = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (_isRouteMode) {
          _focusRoute();
        } else {
          _moveTo(LatLng(position.latitude, position.longitude), zoom: 14.5);
        }
      });

      if (_isRouteMode) {
        _startLiveNavigation();
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingLocation = false;
        _isLoadingRoute = false;
        _locationMessage = 'Gagal mengambil lokasi. Coba lagi beberapa saat.';
      });
    }
  }

  void _startLiveNavigation() {
    _positionSubscription?.cancel();
    _isNavigationPaused = false;
    const settings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 5,
    );

    _positionSubscription =
        Geolocator.getPositionStream(locationSettings: settings).listen(
          _handlePositionUpdate,
          onError: (_) {
            if (!mounted) return;
            setState(() {
              _locationMessage =
                  'Pembaruan lokasi langsung terhenti. Pastikan GPS tetap aktif.';
            });
          },
        );
  }

  void _handlePositionUpdate(Position position) {
    if (!mounted || !_isRouteMode || _isNavigationPaused) return;

    final destination = widget.destinationPlace!;
    final remainingDistance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      destination.latitude,
      destination.longitude,
    );

    final currentPoint = LatLng(position.latitude, position.longitude);
    final shouldAddTrail =
        _travelledPoints.isEmpty ||
        Geolocator.distanceBetween(
              _travelledPoints.last.latitude,
              _travelledPoints.last.longitude,
              currentPoint.latitude,
              currentPoint.longitude,
            ) >=
            3;
    final offRouteDistance = _distanceFromRoute(currentPoint);

    setState(() {
      _currentPosition = position;
      _hasArrived = remainingDistance <= 35;
      _isOffRoute = _routePoints.isNotEmpty && offRouteDistance > 60;
      if (shouldAddTrail) {
        _travelledPoints.add(currentPoint);
        if (_travelledPoints.length > 500) {
          _travelledPoints.removeAt(0);
        }
      }
    });

    if (_followUser) {
      _mapController.move(
        LatLng(position.latitude, position.longitude),
        math.max(_currentZoom, 16),
      );
      _currentZoom = math.max(_currentZoom, 16);
    }

    if (_hasArrived) {
      setState(() {
        _routePoints = [];
        _currentRouteDistance = 0;
      });
      return;
    }

    unawaited(_refreshRoute(position, force: _isOffRoute));
  }

  double _distanceFromRoute(LatLng point) {
    if (_routePoints.isEmpty) return 0;

    var nearestDistance = double.infinity;
    for (final routePoint in _routePoints) {
      final distance = Geolocator.distanceBetween(
        point.latitude,
        point.longitude,
        routePoint.latitude,
        routePoint.longitude,
      );
      if (distance < nearestDistance) {
        nearestDistance = distance;
      }
    }
    return nearestDistance;
  }

  double _calculateRouteDistance(List<LatLng> points) {
    if (points.length < 2) return 0;

    var total = 0.0;
    for (var index = 1; index < points.length; index++) {
      total += Geolocator.distanceBetween(
        points[index - 1].latitude,
        points[index - 1].longitude,
        points[index].latitude,
        points[index].longitude,
      );
    }
    return total;
  }

  void _toggleNavigation() {
    if (_isNavigationPaused) {
      setState(() {
        _isNavigationPaused = false;
        _followUser = true;
        _locationMessage = null;
      });
      _startLiveNavigation();
      return;
    }

    _positionSubscription?.cancel();
    setState(() {
      _isNavigationPaused = true;
      _followUser = false;
      _locationMessage = 'Navigasi dijeda. Posisi tidak diperbarui sementara.';
    });
  }

  Future<void> _refreshRoute(Position position, {bool force = false}) async {
    if (!_isRouteMode || _isRefreshingRoute) return;

    final now = DateTime.now();
    final origin = LatLng(position.latitude, position.longitude);
    final movedDistance = _lastRouteOrigin == null
        ? double.infinity
        : Geolocator.distanceBetween(
            _lastRouteOrigin!.latitude,
            _lastRouteOrigin!.longitude,
            origin.latitude,
            origin.longitude,
          );
    final secondsSinceUpdate = _lastRouteUpdate == null
        ? double.infinity
        : now.difference(_lastRouteUpdate!).inSeconds.toDouble();

    if (force && secondsSinceUpdate < 8) return;
    if (!force && (movedDistance < 20 || secondsSinceUpdate < 12)) return;

    _isRefreshingRoute = true;
    if (mounted && !force) {
      setState(() {});
    }

    try {
      final destination = widget.destinationPlace!;
      final points = await RouteService.getRouteCoordinates(
        start: origin,
        end: LatLng(destination.latitude, destination.longitude),
      );
      if (!mounted) return;
      final routeDistance = _calculateRouteDistance(points);

      setState(() {
        _routePoints = points;
        _currentRouteDistance = routeDistance;
        _initialRouteDistance ??= routeDistance;
        _lastRouteOrigin = origin;
        _lastRouteUpdate = now;
        _isOffRoute = false;
        _locationMessage = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _locationMessage =
            'Rute belum dapat diperbarui. Posisi GPS tetap berjalan.';
      });
    } finally {
      _isRefreshingRoute = false;
      if (mounted) {
        setState(() {});
      }
    }
  }

  void _moveTo(LatLng point, {double? zoom}) {
    final targetZoom = (zoom ?? _currentZoom).clamp(3.0, 18.0);
    _mapController.move(point, targetZoom);
    setState(() => _currentZoom = targetZoom);
  }

  void _focusRoute() {
    final destination = widget.destinationPlace;
    final position = _currentPosition;

    if (destination == null) return;
    if (position == null) {
      _moveTo(LatLng(destination.latitude, destination.longitude), zoom: 15);
      return;
    }

    final center = LatLng(
      (position.latitude + destination.latitude) / 2,
      (position.longitude + destination.longitude) / 2,
    );
    final distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      destination.latitude,
      destination.longitude,
    );
    final zoom = distance < 1200
        ? 15.0
        : distance < 3000
        ? 13.8
        : distance < 8000
        ? 12.2
        : 10.5;

    _moveTo(center, zoom: zoom);
  }

  void _selectPlace(PlaceModel place) {
    _searchFocusNode.unfocus();
    setState(() => _selectedPlace = place);
    _moveTo(LatLng(place.latitude, place.longitude), zoom: 16);
  }

  List<PlaceModel> _filteredPlaces(List<PlaceModel> places) {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return places;

    return places.where((place) {
      return place.name.toLowerCase().contains(query) ||
          place.category.toLowerCase().contains(query) ||
          place.address.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PlaceProvider>();
    final filteredPlaces = _filteredPlaces(provider.places);
    final topPadding = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: _surface,
      body: Stack(
        children: [
          Positioned.fill(child: _buildMap(provider, filteredPlaces)),
          Positioned(
            top: topPadding + 12,
            left: 16,
            right: 16,
            child: _buildTopPanel(provider, filteredPlaces),
          ),
          Positioned(
            right: 16,
            bottom: _isRouteMode
                ? 238
                : _selectedPlace == null
                ? 32
                : 190,
            child: _buildMapControls(),
          ),
          if (_locationMessage != null)
            Positioned(
              top: topPadding + (_isRouteMode ? 84 : 146),
              left: 16,
              right: 16,
              child: _buildMessageBanner(),
            ),
          if (_isRouteMode)
            Positioned(
              left: 16,
              right: 16,
              bottom: 18,
              child: _buildNavigationPanel(),
            )
          else if (_selectedPlace != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 18,
              child: _buildPlacePreview(_selectedPlace!),
            ),
          if (_isLoadingLocation || provider.isLoading)
            Positioned.fill(child: _buildLoadingOverlay()),
        ],
      ),
    );
  }

  Widget _buildMap(PlaceProvider provider, List<PlaceModel> filteredPlaces) {
    final initialCenter = _isRouteMode
        ? LatLng(
            widget.destinationPlace!.latitude,
            widget.destinationPlace!.longitude,
          )
        : const LatLng(-7.2575, 112.7521);

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: initialCenter,
        initialZoom: 14,
        minZoom: 3,
        maxZoom: 18,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
        onTap: (_, _) {
          _searchFocusNode.unfocus();
          if (!_isRouteMode) {
            setState(() => _selectedPlace = null);
          }
        },
        onPositionChanged: (camera, hasGesture) {
          _currentZoom = camera.zoom;
          if (_isRouteMode && hasGesture && _followUser) {
            setState(() => _followUser = false);
          }
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.cloud_computing_2',
          tileBuilder: (context, tileWidget, tile) {
            return ColorFiltered(
              colorFilter: const ColorFilter.matrix([
                0.92,
                0.02,
                0.02,
                0,
                8,
                0.02,
                0.96,
                0.02,
                0,
                8,
                0.02,
                0.02,
                1.02,
                0,
                8,
                0,
                0,
                0,
                1,
                0,
              ]),
              child: tileWidget,
            );
          },
        ),
        if (_routePoints.isNotEmpty)
          PolylineLayer(
            polylines: [
              Polyline(
                points: _routePoints,
                strokeWidth: 10,
                color: Colors.white.withValues(alpha: 0.9),
              ),
              Polyline(points: _routePoints, strokeWidth: 5, color: _blue),
            ],
          ),
        if (_travelledPoints.length > 1)
          PolylineLayer(
            polylines: [
              Polyline(
                points: _travelledPoints,
                strokeWidth: 5,
                color: const Color(0xFF38A169),
              ),
            ],
          ),
        MarkerLayer(
          markers: [
            if (_isRouteMode)
              _buildPlaceMarker(widget.destinationPlace!, isDestination: true)
            else
              ...filteredPlaces.map(
                (place) => _buildPlaceMarker(
                  place,
                  isSelected: _selectedPlace?.id == place.id,
                ),
              ),
            if (_currentPosition != null) _buildUserMarker(),
          ],
        ),
        RichAttributionWidget(
          attributions: const [
            TextSourceAttribution('OpenStreetMap contributors'),
          ],
        ),
      ],
    );
  }

  Marker _buildPlaceMarker(
    PlaceModel place, {
    bool isSelected = false,
    bool isDestination = false,
  }) {
    final active = isSelected || isDestination;

    return Marker(
      point: LatLng(place.latitude, place.longitude),
      width: active ? 150 : 56,
      height: active ? 88 : 56,
      alignment: Alignment.topCenter,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _selectPlace(place),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (active)
              Container(
                constraints: const BoxConstraints(maxWidth: 145),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _navy,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: _navy.withValues(alpha: 0.22),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Text(
                  place.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            Container(
              width: active ? 42 : 38,
              height: active ? 42 : 38,
              decoration: BoxDecoration(
                color: active ? _blue : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: active ? Colors.white : _blue,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _navy.withValues(alpha: 0.2),
                    blurRadius: 9,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.handyman_rounded,
                size: active ? 22 : 20,
                color: active ? Colors.white : _blue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Marker _buildUserMarker() {
    final isNavigating = _isRouteMode;
    final heading = _currentPosition!.heading.isFinite
        ? _currentPosition!.heading
        : 0.0;

    return Marker(
      point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
      width: 68,
      height: 68,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: _blue.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
          ),
          Transform.rotate(
            angle: isNavigating ? heading * math.pi / 180 : 0,
            child: Container(
              width: isNavigating ? 38 : 24,
              height: isNavigating ? 38 : 24,
              decoration: BoxDecoration(
                color: _blue,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: _blue.withValues(alpha: 0.35),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: isNavigating
                  ? const Icon(
                      Icons.navigation_rounded,
                      color: Colors.white,
                      size: 20,
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopPanel(
    PlaceProvider provider,
    List<PlaceModel> filteredPlaces,
  ) {
    if (_isRouteMode) {
      final remainingDistance = _remainingDistance;
      final navigationLabel = _isNavigationPaused
          ? 'NAVIGASI DIJEDA'
          : _isOffRoute
          ? 'MENGHITUNG ULANG RUTE'
          : _hasArrived
          ? 'ANDA SUDAH TIBA'
          : remainingDistance == null
          ? 'MENCARI POSISI GPS'
          : 'NAVIGASI LANGSUNG - ${_formatDistance(remainingDistance)}';

      return _glassCard(
        child: Row(
          children: [
            _buildBackButton(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    navigationLabel,
                    style: TextStyle(
                      color: _hasArrived
                          ? Colors.green.shade700
                          : _isOffRoute
                          ? Colors.orange.shade800
                          : _blue,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    widget.destinationPlace!.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _navy,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            if (_isLoadingRoute || _isRefreshingRoute)
              const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: _blue,
                  strokeWidth: 2.5,
                ),
              )
            else
              IconButton(
                tooltip: 'Lihat seluruh rute',
                onPressed: _focusRoute,
                icon: const Icon(Icons.route_rounded, color: _blue),
              ),
          ],
        ),
      );
    }

    return Column(
      children: [
        _glassCard(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
          child: Row(
            children: [
              _buildBackButton(),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  onChanged: (value) => setState(() => _searchQuery = value),
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Cari bengkel di peta',
                    hintStyle: TextStyle(
                      color: Colors.blueGrey.shade400,
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(Icons.search_rounded, color: _blue),
                    suffixIcon: _searchQuery.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                            icon: const Icon(Icons.close_rounded, size: 20),
                          ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _navy,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: _navy.withValues(alpha: 0.18),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.storefront_rounded,
                  color: Colors.white,
                  size: 15,
                ),
                const SizedBox(width: 7),
                Text(
                  provider.errorMessage.isNotEmpty
                      ? 'Data bengkel gagal dimuat'
                      : '${filteredPlaces.length} bengkel ditemukan',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBackButton() {
    return IconButton(
      tooltip: 'Kembali',
      onPressed: () => Navigator.maybePop(context),
      icon: const Icon(Icons.arrow_back_rounded, color: _navy),
    );
  }

  Widget _buildMapControls() {
    return Column(
      children: [
        _controlButton(
          icon: Icons.add_rounded,
          tooltip: 'Perbesar',
          onTap: () {
            _moveTo(
              _mapController.camera.center,
              zoom: math.min(_currentZoom + 1, 18),
            );
          },
        ),
        const SizedBox(height: 8),
        _controlButton(
          icon: Icons.remove_rounded,
          tooltip: 'Perkecil',
          onTap: () {
            _moveTo(
              _mapController.camera.center,
              zoom: math.max(_currentZoom - 1, 3),
            );
          },
        ),
        const SizedBox(height: 12),
        _controlButton(
          icon: _isRouteMode && _followUser
              ? Icons.navigation_rounded
              : Icons.my_location_rounded,
          tooltip: _isRouteMode ? 'Ikuti posisi saya' : 'Lokasi saya',
          highlighted: !_isRouteMode || _followUser,
          onTap: () {
            if (_isRouteMode) {
              setState(() => _followUser = true);
              if (_currentPosition != null) {
                _moveTo(
                  LatLng(
                    _currentPosition!.latitude,
                    _currentPosition!.longitude,
                  ),
                  zoom: 16,
                );
              }
            } else if (_currentPosition != null) {
              _moveTo(
                LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                zoom: 15,
              );
            } else {
              _initializeMap();
            }
          },
        ),
      ],
    );
  }

  Widget _controlButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    bool highlighted = false,
  }) {
    return Material(
      color: highlighted ? _navy : Colors.white,
      elevation: 5,
      shadowColor: _navy.withValues(alpha: 0.18),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Tooltip(
          message: tooltip,
          child: SizedBox(
            width: 46,
            height: 46,
            child: Icon(
              icon,
              color: highlighted ? Colors.white : _navy,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationPanel() {
    final remainingDistance = _currentRouteDistance > 0
        ? _currentRouteDistance
        : (_remainingDistance ?? 0);
    final accuracy = _currentPosition?.accuracy ?? 0;

    return _glassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _hasArrived
                      ? Colors.green.withValues(alpha: 0.12)
                      : _sky,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  _hasArrived
                      ? Icons.flag_circle_rounded
                      : Icons.navigation_rounded,
                  color: _hasArrived ? Colors.green.shade700 : _blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _hasArrived
                          ? 'Tujuan telah tercapai'
                          : _isOffRoute
                          ? 'Menyesuaikan rute baru'
                          : 'Perjalanan sedang berlangsung',
                      style: const TextStyle(
                        color: _navy,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.destinationPlace!.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.blueGrey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Material(
                color: _isNavigationPaused ? const Color(0xFF38A169) : _navy,
                borderRadius: BorderRadius.circular(13),
                child: InkWell(
                  onTap: _toggleNavigation,
                  borderRadius: BorderRadius.circular(13),
                  child: SizedBox(
                    width: 44,
                    height: 44,
                    child: Icon(
                      _isNavigationPaused
                          ? Icons.play_arrow_rounded
                          : Icons.pause_rounded,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _hasArrived ? 1 : _navigationProgress,
              minHeight: 7,
              backgroundColor: _sky,
              color: _hasArrived ? const Color(0xFF38A169) : _blue,
            ),
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              _navigationMetric(
                icon: Icons.schedule_rounded,
                label: 'Estimasi',
                value: _estimatedTime,
              ),
              _metricDivider(),
              _navigationMetric(
                icon: Icons.route_rounded,
                label: 'Sisa',
                value: _formatDistance(remainingDistance),
              ),
              _metricDivider(),
              _navigationMetric(
                icon: Icons.speed_rounded,
                label: 'Kecepatan',
                value: _speedLabel,
              ),
              _metricDivider(),
              _navigationMetric(
                icon: Icons.gps_fixed_rounded,
                label: 'Akurasi',
                value: accuracy > 0 ? '${accuracy.round()} m' : '-',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _navigationMetric({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: _blue, size: 17),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _navy,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.blueGrey.shade400,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricDivider() {
    return Container(
      width: 1,
      height: 32,
      color: Colors.blueGrey.withValues(alpha: 0.15),
    );
  }

  Widget _buildPlacePreview(PlaceModel place) {
    return _glassCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_navy, _blue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.handyman_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        place.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _navy,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.star_rounded,
                      color: Color(0xFFF6AD55),
                      size: 18,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      place.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        color: _navy,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  place.address.isEmpty ? place.category : place.address,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.blueGrey.shade500,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _infoPill(Icons.category_rounded, place.category),
                    if (place.distance > 0) ...[
                      const SizedBox(width: 7),
                      _infoPill(
                        Icons.near_me_rounded,
                        '${place.distance.toStringAsFixed(1)} km',
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoPill(IconData icon, String text) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _sky,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: _blue, size: 12),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _blue,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBanner() {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 6, 10),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBEB),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFF6AD55)),
          boxShadow: [
            BoxShadow(
              color: _navy.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(
              Icons.info_outline_rounded,
              color: Color(0xFFB7791F),
              size: 20,
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                _locationMessage!,
                style: const TextStyle(
                  color: Color(0xFF744210),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: () => setState(() => _locationMessage = null),
              icon: const Icon(
                Icons.close_rounded,
                color: Color(0xFFB7791F),
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return ColoredBox(
      color: Colors.white.withValues(alpha: 0.76),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: _navy.withValues(alpha: 0.14),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 25,
                height: 25,
                child: CircularProgressIndicator(color: _blue, strokeWidth: 3),
              ),
              const SizedBox(width: 14),
              Text(
                _isRouteMode ? 'Menyiapkan rute...' : 'Menyiapkan peta...',
                style: const TextStyle(
                  color: _navy,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _glassCard({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(10),
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(
            color: _navy.withValues(alpha: 0.14),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

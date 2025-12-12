import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/location_service.dart';
import '../services/run_tracker_service.dart';

/// Displays the OpenStreetMap with a live location marker and route polyline.
class MapView extends StatefulWidget {
  final LocationService locationService;
  final RunTrackerService runTracker;

  const MapView({
    super.key,
    required this.locationService,
    required this.runTracker,
  });

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  late final MapController _mapController;
  bool _autoCenter = true; // Auto-follow user until they interact with map

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _initLocation();
  }

  Future<void> _initLocation() async {
    try {
      await widget.locationService.initialize();
    } catch (e) {
      debugPrint('Location init error: $e');
    }
  }

  /// Re-center map on current position
  void _recenterOnPosition(LatLng pos) {
    _mapController.move(pos, _mapController.camera.zoom);
    setState(() {
      _autoCenter = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return StreamBuilder<LatLng>(
      stream: widget.locationService.positionStream,
      initialData: widget.locationService.currentPosition,
      builder: (context, snapshot) {
        final pos = snapshot.data;

        // Auto-center map when location updates (if enabled)
        if (pos != null && _autoCenter) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _mapController.move(pos, _mapController.camera.zoom);
            }
          });
        }

        return StreamBuilder<List<LatLng>>(
          stream: widget.runTracker.routeStream,
          initialData: widget.runTracker.routePoints,
          builder: (context, routeSnapshot) {
            final routePoints = routeSnapshot.data ?? [];

            return Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: const LatLng(37.7749, -122.4194),
                    initialZoom: 15,
                    onPositionChanged: (position, hasGesture) {
                      // Disable auto-center when user manually moves the map
                      if (hasGesture && _autoCenter) {
                        setState(() {
                          _autoCenter = false;
                        });
                      }
                    },
                  ),
                  children: [
                    // OpenStreetMap tiles.
                    TileLayer(
                      urlTemplate:
                          'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c'],
                      userAgentPackageName: 'run_tracker_demo',
                    ),

                    // Route polyline
                    if (routePoints.length > 1)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: routePoints,
                            color: Colors.blue,
                            strokeWidth: 4.0,
                          ),
                        ],
                      ),

                    // Live location marker - always updates regardless of auto-center
                    if (pos != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: pos,
                            width: 40,
                            height: 40,
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.my_location,
                              color: colorScheme.primary,
                              size: 28,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),

                // Re-center button (only show when auto-center is disabled)
                if (pos != null && !_autoCenter)
                  Positioned(
                    right: 16,
                    bottom: 130,
                    child: FloatingActionButton(
                      heroTag: 'recenter',
                      mini: true,
                      backgroundColor: colorScheme.surface,
                      foregroundColor: colorScheme.primary,
                      onPressed: () => _recenterOnPosition(pos),
                      child: const Icon(Icons.my_location),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

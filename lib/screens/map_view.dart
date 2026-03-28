import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/location_service.dart';
import '../services/run_tracker_service.dart';
import '../services/run_persistence_service.dart';
import '../services/step_counter_service.dart';
import 'run_details_sheet.dart';
import '../widgets/bottom_controls.dart';

/// Displays the OpenStreetMap with a live location marker.
class MapView extends StatefulWidget {
  final RunPersistenceService? persistence;

  const MapView({super.key, this.persistence});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  late final LocationService _locationService;
  late final RunTrackerService _runTracker;
  late final StepCounterService _stepCounter;
  late final DraggableScrollableController _sheetController;
  late final MapController _mapController;
  bool _autoCenter = true; // Auto-follow user until they interact with map

  @override
  void initState() {
    super.initState();
    _locationService = LocationService();
    _stepCounter = StepCounterService();
    _sheetController = DraggableScrollableController();
    _runTracker = RunTrackerService(
      locationService: _locationService,
      persistence: widget.persistence,
      stepCounter: _stepCounter,
    );
    _mapController = MapController();
    _initLocation();
  }

  Future<void> _initLocation() async {
    try {
      await _locationService.initialize();
    } catch (e) {
      debugPrint('Location init error: $e');
    }
  }

  @override
  void dispose() {
    _locationService.dispose();
    _runTracker.dispose();
    super.dispose();
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
      stream: _locationService.positionStream,
      initialData: _locationService.currentPosition,
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

                // Realtime route polyline (collected by RunTrackerService)
                ValueListenableBuilder<List<LatLng>>(
                  valueListenable: _runTracker.routePoints,
                  builder: (context, points, _) {
                    if (points.length < 2) return const SizedBox.shrink();
                    return PolylineLayer(
                      polylines: [
                        Polyline(
                          points: points,
                          color: colorScheme.primary.withOpacity(0.9),
                          strokeWidth: 4.0,
                        ),
                      ],
                    );
                  },
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
                bottom: 113,
                child: FloatingActionButton(
                  heroTag: 'recenter',
                  mini: true,
                  backgroundColor: colorScheme.surface,
                  foregroundColor: colorScheme.primary,
                  onPressed: () => _recenterOnPosition(pos),
                  child: const Icon(Icons.my_location),
                ),
              ),

            // Run details sheet (draggable) - must be above the map, below bottom controls
            RunDetailsSheet(
              controller: _sheetController,
              runTracker: _runTracker,
            ),

            // Bottom controls are fixed and must not move with the sheet
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: BottomControls(runTracker: _runTracker),
            ),
          ],
        );
      },
    );
  }
}

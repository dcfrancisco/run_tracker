import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/location_service.dart';

/// Displays the OpenStreetMap with a live location marker.
class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  late final LocationService _locationService;
  late final MapController _mapController;
  bool _centeredOnce = false;

  @override
  void initState() {
    super.initState();
    _locationService = LocationService();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return StreamBuilder<LatLng>(
      stream: _locationService.positionStream,
      initialData: _locationService.currentPosition,
      builder: (context, snapshot) {
        final pos = snapshot.data;

        // Center map once when location is acquired.
        if (pos != null && !_centeredOnce) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _mapController.move(pos, 15);
            }
          });
          _centeredOnce = true;
        }

        return FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: const LatLng(37.7749, -122.4194),
            initialZoom: 12,
          ),
          children: [
            // OpenStreetMap tiles.
            TileLayer(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: const ['a', 'b', 'c'],
              userAgentPackageName: 'run_tracker_demo',
            ),

            // Live location marker.
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
        );
      },
    );
  }
}

import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

/// Provides live location updates and permission handling.
class LocationService {
  final _controller = StreamController<LatLng>.broadcast();
  StreamSubscription<Position>? _sub;

  LatLng? _current;
  bool _initialized = false;

  /// Last known position converted to LatLng.
  LatLng? get currentPosition => _current;

  /// A broadcast stream of LatLng updates.
  Stream<LatLng> get positionStream => _controller.stream;

  /// Initialize permissions and start listening to location updates.
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _initialized = true;
        return;
      }
    } catch (e) {
      _initialized = true;
      return;
    }

    LocationPermission permission;
    try {
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        _initialized = true;
        return;
      }
    } catch (e) {
      _initialized = true;
      return;
    }

    const settings = LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 5, // meters; reduce noise
    );

    _sub = Geolocator.getPositionStream(locationSettings: settings).listen(
      (pos) {
        final latLng = LatLng(pos.latitude, pos.longitude);
        _current = latLng;
        if (!_controller.isClosed) {
          _controller.add(latLng);
        }
      },
      onError: (error) {
        // Silently handle location stream errors
      },
    );

    // Also seed with a last known position if available.
    try {
      final last = await Geolocator.getLastKnownPosition();
      if (last != null) {
        final latLng = LatLng(last.latitude, last.longitude);
        _current = latLng;
        _controller.add(latLng);
      }
    } catch (_) {}

    _initialized = true;
  }

  Future<void> dispose() async {
    await _sub?.cancel();
    await _controller.close();
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:run_tracker/utils/run_metrics.dart';

void main() {
  test('calculateDistanceKm returns 0 for fewer than 2 points', () {
    final pts = <LatLng>[];
    expect(RunMetrics.calculateDistanceKm(pts), 0.0);
  });

  test('calculatePaceMinPerKm, speed and calories basic checks', () {
    // pace: 30 minutes over 5 km -> 6.0 min/km
    final duration = Duration(minutes: 30);
    final pace = RunMetrics.calculatePaceMinPerKm(duration, 5.0);
    expect(pace, closeTo(6.0, 1e-6));

    // speed: 0.5 hours for 10 km -> 20 km/h
    final speed = RunMetrics.calculateSpeedKmh(Duration(minutes: 30), 10.0);
    expect(speed, closeTo(20.0, 1e-6));

    // calories: weight 70kg over 10 km
    final calories = RunMetrics.calculateCalories(70.0, 10.0);
    expect(calories, closeTo(70.0 * 10.0 * 1.036, 1e-6));
  });

  test('calculateDistanceKm for two known points', () {
    final a = LatLng(0.0, 0.0);
    final b = LatLng(0.0, 0.009); // ~1 km at equator
    final d = RunMetrics.calculateDistanceKm([a, b]);
    expect(d, greaterThan(0.9));
    expect(d, lessThan(1.2));
  });
}

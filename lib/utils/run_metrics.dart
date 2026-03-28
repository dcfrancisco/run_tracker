import 'package:latlong2/latlong.dart';

/// Utility class for calculating run metrics: distance, pace, speed, calories.
class RunMetrics {
  static final _dist = Distance();

  /// Calculate total distance in kilometers for the given ordered list of points.
  static double calculateDistanceKm(List<LatLng> points) {
    if (points.length < 2) return 0.0;

    double meters = 0.0;
    for (var i = 0; i < points.length - 1; i++) {
      meters += _dist.as(LengthUnit.Meter, points[i], points[i + 1]);
    }
    return meters / 1000.0;
  }

  /// Pace in minutes per km. Returns 0 if distance is zero.
  static double calculatePaceMinPerKm(Duration duration, double distanceKm) {
    if (distanceKm <= 0) return 0.0;
    final minutes = duration.inSeconds / 60.0;
    return minutes / distanceKm;
  }

  /// Speed in km/h. Returns 0 if duration is zero or distance is zero.
  static double calculateSpeedKmh(Duration duration, double distanceKm) {
    if (duration.inSeconds == 0 || distanceKm <= 0) return 0.0;
    final hours = duration.inSeconds / 3600.0;
    return distanceKm / hours;
  }

  /// Estimate calories burned.
  /// Formula: calories = weightKg * distanceKm * 1.036
  static double calculateCalories(double weightKg, double distanceKm) {
    return weightKg * distanceKm * 1.036;
  }
}

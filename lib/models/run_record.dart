import 'package:latlong2/latlong.dart';

/// Data model representing a completed run or bike activity.
class RunRecord {
  final List<LatLng> points;
  final double distanceKm;
  final double pace; // minutes per km
  final double speed; // km/h
  final double calories;
  final int steps;
  final DateTime date;

  RunRecord({
    required this.points,
    required this.distanceKm,
    required this.pace,
    required this.speed,
    required this.calories,
    required this.steps,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    'points': points
        .map((p) => {'lat': p.latitude, 'lng': p.longitude})
        .toList(),
    'distanceKm': distanceKm,
    'pace': pace,
    'speed': speed,
    'calories': calories,
    'steps': steps,
    'date': date.toIso8601String(),
  };

  factory RunRecord.fromJson(Map<String, dynamic> json) {
    final pts = <LatLng>[];
    if (json['points'] is List) {
      for (final p in json['points']) {
        if (p is Map) {
          final lat = (p['lat'] as num).toDouble();
          final lng = (p['lng'] as num).toDouble();
          pts.add(LatLng(lat, lng));
        }
      }
    }

    return RunRecord(
      points: pts,
      distanceKm: (json['distanceKm'] as num).toDouble(),
      pace: (json['pace'] as num).toDouble(),
      speed: (json['speed'] as num).toDouble(),
      calories: (json['calories'] as num).toDouble(),
      steps: (json['steps'] as num).toInt(),
      date: DateTime.parse(json['date'] as String),
    );
  }
}

/// Run data model for tracking run metrics.
class RunData {
  final double distanceKm;
  final Duration elapsedTime;
  final double paceMinPerKm;
  final double speedKmH;
  final double caloriesBurned;
  final int stepCount;
  final double elevationGainM;

  const RunData({
    required this.distanceKm,
    required this.elapsedTime,
    required this.paceMinPerKm,
    required this.speedKmH,
    required this.caloriesBurned,
    required this.stepCount,
    required this.elevationGainM,
  });

  /// Factory for creating initial/empty run data.
  factory RunData.empty() {
    return const RunData(
      distanceKm: 0.0,
      elapsedTime: Duration.zero,
      paceMinPerKm: 0.0,
      speedKmH: 0.0,
      caloriesBurned: 0.0,
      stepCount: 0,
      elevationGainM: 0.0,
    );
  }

  /// Format elapsed time as HH:MM:SS.
  String get formattedTime {
    final hours = elapsedTime.inHours;
    final minutes = elapsedTime.inMinutes % 60;
    final seconds = elapsedTime.inSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Format pace as M:SS /km.
  String get formattedPace {
    final mins = paceMinPerKm.toInt();
    final secs = ((paceMinPerKm - mins) * 60).toInt();
    return '$mins:${secs.toString().padLeft(2, '0')} /km';
  }
}

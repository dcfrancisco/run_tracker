import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import '../services/step_counter_service.dart';

import '../models/run_record.dart';
import '../services/location_service.dart';
import '../services/run_persistence_service.dart';
import '../utils/run_metrics.dart';

/// Represents the lifecycle state of a run.
enum RunState { idle, running, paused, finished }

/// Service that manages run lifecycle and collects GPS points while running.
class RunTrackerService {
  final LocationService locationService;
  final RunPersistenceService? persistence;
  final StepCounterService? stepCounter;
  final double weightKg;

  RunTrackerService({
    required this.locationService,
    this.persistence,
    this.stepCounter,
    this.weightKg = 70.0,
  });

  final ValueNotifier<RunState> state = ValueNotifier(RunState.idle);
  final ValueNotifier<List<LatLng>> routePoints = ValueNotifier<List<LatLng>>(
    [],
  );
  final ValueNotifier<RunRecord?> lastRun = ValueNotifier<RunRecord?>(null);

  StreamSubscription<LatLng?>? _locSub;
  DateTime? _startTime;
  DateTime? _endTime;
  Duration _accumPaused = Duration.zero;
  DateTime? _pauseStart;

  void dispose() {
    _locSub?.cancel();
    state.dispose();
    routePoints.dispose();
    lastRun.dispose();
    // start step monitoring if available
    try {
      stepCounter?.start();
    } catch (_) {}
  }

  Future<void> startRun() async {
    // reset
    routePoints.value = [];
    _accumPaused = Duration.zero;
    _pauseStart = null;
    _startTime = DateTime.now();
    _endTime = null;
    state.value = RunState.running;

    // start step monitoring if available
    try {
      stepCounter?.start();
    } catch (_) {}

    // subscribe to location updates
    _locSub = locationService.positionStream.listen((pos) {
      final copy = List<LatLng>.from(routePoints.value)..add(pos);
      routePoints.value = copy;
    });
  }

  Future<void> pauseRun() async {
    if (state.value != RunState.running) return;
    _pauseStart = DateTime.now();
    state.value = RunState.paused;
    await _locSub?.cancel();
    _locSub = null;
  }

  Future<void> resumeRun() async {
    if (state.value != RunState.paused) return;
    // resume step monitoring
    try {
      stepCounter?.start();
    } catch (_) {}
    if (_pauseStart != null) {
      _accumPaused += DateTime.now().difference(_pauseStart!);
      _pauseStart = null;
    }
    state.value = RunState.running;
    _locSub = locationService.positionStream.listen((pos) {
      final copy = List<LatLng>.from(routePoints.value)..add(pos);
      routePoints.value = copy;
    });
  }

  Future<void> stopRun() async {
    if (state.value == RunState.idle) return;
    await _locSub?.cancel();
    _locSub = null;
    _endTime = DateTime.now();
    state.value = RunState.finished;

    final duration = _computeActiveDuration();
    final distanceKm = RunMetrics.calculateDistanceKm(routePoints.value);
    final pace = RunMetrics.calculatePaceMinPerKm(duration, distanceKm);
    final speed = RunMetrics.calculateSpeedKmh(duration, distanceKm);
    final calories = RunMetrics.calculateCalories(weightKg, distanceKm);
    final steps = stepCounter?.stepCount.value ?? 0;

    // stop step monitoring
    try {
      stepCounter?.stop();
    } catch (_) {}

    final record = RunRecord(
      points: routePoints.value,
      distanceKm: distanceKm,
      pace: pace,
      speed: speed,
      calories: calories,
      steps: steps,
      date: _startTime ?? DateTime.now(),
    );

    lastRun.value = record;

    // persist using Hive if available
    try {
      await persistence?.saveRun(record);
    } catch (_) {}

    // keep routePoints intact for UI
  }

  Duration _computeActiveDuration() {
    if (_startTime == null) return Duration.zero;
    final end = _endTime ?? DateTime.now();
    final raw = end.difference(_startTime!);
    return raw - _accumPaused;
  }

  /// Public accessor for the currently active duration (excluding pauses).
  Duration getActiveDuration() => _computeActiveDuration();

  /// Current accumulated distance in kilometers.
  double get currentDistanceKm =>
      RunMetrics.calculateDistanceKm(routePoints.value);

  /// Current pace in minutes per km.
  double get currentPaceMinPerKm =>
      RunMetrics.calculatePaceMinPerKm(getActiveDuration(), currentDistanceKm);

  /// Current speed in km/h.
  double get currentSpeedKmh =>
      RunMetrics.calculateSpeedKmh(getActiveDuration(), currentDistanceKm);

  /// Current calories estimate based on `weightKg`.
  double get currentCalories =>
      RunMetrics.calculateCalories(weightKg, currentDistanceKm);

  /// Current step count (if stepCounter provided).
  int get currentSteps => stepCounter?.stepCount.value ?? 0;
}

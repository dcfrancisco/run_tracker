import 'dart:async';
import 'package:latlong2/latlong.dart';

/// Enum representing the current state of run tracking.
enum RunState { idle, running, paused, finished }

/// Service for managing run tracking lifecycle and route data.
class RunTrackerService {
  final _stateController = StreamController<RunState>.broadcast();
  final _routeController = StreamController<List<LatLng>>.broadcast();

  RunState _state = RunState.idle;
  final List<LatLng> _routePoints = [];
  DateTime? _startTime;
  DateTime? _endTime;
  Duration _pausedDuration = Duration.zero;
  DateTime? _pauseStartTime;

  /// Current state of the run tracker.
  RunState get state => _state;

  /// Stream of state changes.
  Stream<RunState> get stateStream => _stateController.stream;

  /// Current route points collected during the run.
  List<LatLng> get routePoints => List.unmodifiable(_routePoints);

  /// Stream of route point updates.
  Stream<List<LatLng>> get routeStream => _routeController.stream;

  /// Start time of the current/last run.
  DateTime? get startTime => _startTime;

  /// End time of the finished run.
  DateTime? get endTime => _endTime;

  /// Total elapsed time excluding paused duration.
  Duration get elapsedTime {
    if (_startTime == null) return Duration.zero;

    final end = _endTime ?? DateTime.now();
    final total = end.difference(_startTime!);
    return total - _pausedDuration;
  }

  /// Whether the tracker is currently running (not paused or idle).
  bool get isRunning => _state == RunState.running;

  /// Whether the tracker is paused.
  bool get isPaused => _state == RunState.paused;

  /// Whether the tracker is idle (not started).
  bool get isIdle => _state == RunState.idle;

  /// Whether the run is finished.
  bool get isFinished => _state == RunState.finished;

  /// Start a new run.
  /// Clears previous route points and resets timers.
  void startRun() {
    if (_state != RunState.idle && _state != RunState.finished) {
      return; // Already running or paused
    }

    // Clear previous data
    _routePoints.clear();
    _startTime = DateTime.now();
    _endTime = null;
    _pausedDuration = Duration.zero;
    _pauseStartTime = null;

    // Update state
    _state = RunState.running;
    _stateController.add(_state);
    _routeController.add(_routePoints);
  }

  /// Pause the current run.
  /// Tracks the pause start time to calculate total paused duration.
  void pauseRun() {
    if (_state != RunState.running) return;

    _pauseStartTime = DateTime.now();
    _state = RunState.paused;
    _stateController.add(_state);
  }

  /// Resume the paused run.
  /// Adds the paused duration to the total paused time.
  void resumeRun() {
    if (_state != RunState.paused) return;

    if (_pauseStartTime != null) {
      final pauseDuration = DateTime.now().difference(_pauseStartTime!);
      _pausedDuration += pauseDuration;
      _pauseStartTime = null;
    }

    _state = RunState.running;
    _stateController.add(_state);
  }

  /// Stop the current run and mark it as finished.
  /// Captures the end time for duration calculation.
  void stopRun() {
    if (_state != RunState.running && _state != RunState.paused) return;

    // If paused, add final pause duration
    if (_pauseStartTime != null) {
      final pauseDuration = DateTime.now().difference(_pauseStartTime!);
      _pausedDuration += pauseDuration;
      _pauseStartTime = null;
    }

    _endTime = DateTime.now();
    _state = RunState.finished;
    _stateController.add(_state);
  }

  /// Reset the tracker to idle state.
  /// Clears all run data and prepares for a new run.
  void reset() {
    _routePoints.clear();
    _startTime = null;
    _endTime = null;
    _pausedDuration = Duration.zero;
    _pauseStartTime = null;
    _state = RunState.idle;
    _stateController.add(_state);
    _routeController.add(_routePoints);
  }

  /// Add a GPS point to the current route.
  /// Only adds points when the run is actively running (not paused).
  void addRoutePoint(LatLng point) {
    if (_state != RunState.running) return;

    _routePoints.add(point);
    _routeController.add(_routePoints);
  }

  /// Dispose of resources.
  Future<void> dispose() async {
    await _stateController.close();
    await _routeController.close();
  }
}

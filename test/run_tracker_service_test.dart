import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/foundation.dart';
import 'package:run_tracker/services/run_tracker_service.dart';
import 'package:run_tracker/services/location_service.dart';
import 'package:run_tracker/services/step_counter_service.dart';

// Minimal fake LocationService for testing
class FakeLocationService extends LocationService {
  final _ctrl = StreamController<LatLng>.broadcast();
  LatLng? _last;

  @override
  Stream<LatLng> get positionStream => _ctrl.stream;

  @override
  LatLng? get currentPosition => _last;

  @override
  Future<void> initialize() async {}

  void emit(LatLng p) {
    _last = p;
    if (!_ctrl.isClosed) _ctrl.add(p);
  }

  @override
  Future<void> dispose() async {
    await _ctrl.close();
    await super.dispose();
  }
}

// Minimal fake StepCounterService for testing
class FakeStepCounterService extends StepCounterService {
  @override
  void start() {}

  @override
  Future<void> stop() async {}

  void increment() => stepCount.value++;
}

void main() {
  test('RunTrackerService start/pause/resume/stop lifecycle', () async {
    final loc = FakeLocationService();
    final steps = FakeStepCounterService();

    final tracker = RunTrackerService(
      locationService: loc as dynamic,
      stepCounter: steps as dynamic,
    );

    // start run and emit a point
    await tracker.startRun();
    loc.emit(LatLng(0.0, 0.0));
    await Future.microtask(() {});
    expect(tracker.routePoints.value.length, 1);
    expect(tracker.state.value, RunState.running);

    // pause - further points should not be added
    await tracker.pauseRun();
    loc.emit(LatLng(0.001, 0.001));
    await Future.microtask(() {});
    expect(tracker.routePoints.value.length, 1);
    expect(tracker.state.value, RunState.paused);

    // resume and add another point
    await tracker.resumeRun();
    loc.emit(LatLng(0.002, 0.002));
    await Future.microtask(() {});
    expect(tracker.routePoints.value.length, 2);
    expect(tracker.state.value, RunState.running);

    // stop
    await tracker.stopRun();
    expect(tracker.state.value, RunState.finished);
    expect(tracker.lastRun.value, isNotNull);

    tracker.dispose();
    loc.dispose();
  });
}

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/foundation.dart';
import 'package:run_tracker/services/run_tracker_service.dart';

// Minimal fake LocationService for testing
class FakeLocationService {
  final _ctrl = StreamController<LatLng>.broadcast();
  LatLng? _last;

  Stream<LatLng> get positionStream => _ctrl.stream;
  LatLng? get currentPosition => _last;

  Future<void> initialize() async {}
  void emit(LatLng p) {
    _last = p;
    _ctrl.add(p);
  }

  void dispose() => _ctrl.close();
}

// Minimal fake StepCounterService for testing
class FakeStepCounterService {
  final ValueNotifier<int> stepCount = ValueNotifier<int>(0);
  void start() {}
  void stop() {}
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
    await Future.delayed(const Duration(milliseconds: 10));
    expect(tracker.routePoints.value.length, 1);
    expect(tracker.state.value, RunState.running);

    // pause - further points should not be added
    await tracker.pauseRun();
    loc.emit(LatLng(0.001, 0.001));
    await Future.delayed(const Duration(milliseconds: 10));
    expect(tracker.routePoints.value.length, 1);
    expect(tracker.state.value, RunState.paused);

    // resume and add another point
    await tracker.resumeRun();
    loc.emit(LatLng(0.002, 0.002));
    await Future.delayed(const Duration(milliseconds: 10));
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

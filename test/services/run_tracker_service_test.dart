import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:run_tracker/services/run_tracker_service.dart';
import 'package:run_tracker/services/location_service.dart';
import 'package:run_tracker/services/step_counter_service.dart';

class _FakeLocationService extends LocationService {
  final _ctrl = StreamController<LatLng>.broadcast();

  @override
  Stream<LatLng> get positionStream => _ctrl.stream;

  @override
  LatLng? get currentPosition => null;

  void emit(LatLng p) {
    if (!_ctrl.isClosed) _ctrl.add(p);
  }

  @override
  Future<void> dispose() async {
    await _ctrl.close();
    await super.dispose();
  }
}

class _FakeStepCounter extends StepCounterService {
  @override
  void start() {}

  @override
  Future<void> stop() async {}

  Future<void> dispose() async {
    stepCount.dispose();
  }
}

void main() {
  late RunTrackerService service;
  late _FakeLocationService loc;
  late _FakeStepCounter steps;

  setUp(() {
    loc = _FakeLocationService();
    steps = _FakeStepCounter();
    service = RunTrackerService(
      locationService: loc,
      stepCounter: steps as dynamic,
    );
  });

  tearDown(() async {
    await service.dispose();
    await loc.dispose();
    await steps.dispose();
  });

  test('initial state and properties', () {
    expect(service.state.value, RunState.idle);
    expect(service.routePoints.value, isEmpty);
    expect(service.getActiveDuration(), Duration.zero);
    expect(service.currentDistanceKm, 0.0);
  });

  test('start/pause/resume/stop lifecycle with location updates', () async {
    await service.startRun();
    expect(service.state.value, RunState.running);

    loc.emit(const LatLng(0, 0));
    // allow event loop to process the stream synchronously
    await Future.microtask(() {});
    expect(service.routePoints.value.length, 1);

    await service.pauseRun();
    expect(service.state.value, RunState.paused);

    loc.emit(const LatLng(0.001, 0.001));
    await Future.microtask(() {});
    expect(service.routePoints.value.length, 1); // no new point while paused

    await service.resumeRun();
    expect(service.state.value, RunState.running);
    loc.emit(const LatLng(0.002, 0.002));
    await Future.microtask(() {});
    expect(service.routePoints.value.length, 2);

    await service.stopRun();
    expect(service.state.value, RunState.finished);
    expect(service.lastRun.value, isNotNull);
  });
}

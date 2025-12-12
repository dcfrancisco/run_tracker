import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:run_tracker/services/run_tracker_service.dart';

void main() {
  group('RunTrackerService', () {
    late RunTrackerService service;

    setUp(() {
      service = RunTrackerService();
    });

    tearDown(() async {
      await service.dispose();
    });

    group('Initialization', () {
      test('should start in idle state', () {
        expect(service.state, RunState.idle);
        expect(service.isIdle, isTrue);
        expect(service.isRunning, isFalse);
        expect(service.isPaused, isFalse);
        expect(service.isFinished, isFalse);
      });

      test('should have empty route points initially', () {
        expect(service.routePoints, isEmpty);
      });

      test('should have no start or end time initially', () {
        expect(service.startTime, isNull);
        expect(service.endTime, isNull);
      });

      test('should have zero elapsed time initially', () {
        expect(service.elapsedTime, Duration.zero);
      });
    });

    group('Starting a run', () {
      test('should transition from idle to running', () {
        service.startRun();
        expect(service.state, RunState.running);
        expect(service.isRunning, isTrue);
      });

      test('should set start time', () {
        final before = DateTime.now();
        service.startRun();
        final after = DateTime.now();

        expect(service.startTime, isNotNull);
        expect(
          service.startTime!.isAfter(before) ||
              service.startTime!.isAtSameMomentAs(before),
          isTrue,
        );
        expect(
          service.startTime!.isBefore(after) ||
              service.startTime!.isAtSameMomentAs(after),
          isTrue,
        );
      });

      test('should clear previous route points', () {
        service.startRun();
        service.addRoutePoint(const LatLng(37.7749, -122.4194));
        service.stopRun();

        expect(service.routePoints.length, 1);

        service.startRun();
        expect(service.routePoints, isEmpty);
      });

      test('should emit state change event', () async {
        expectLater(service.stateStream, emitsInOrder([RunState.running]));

        service.startRun();
      });

      test('should not start if already running', () async {
        service.startRun();
        final startTime = service.startTime;

        await Future.delayed(const Duration(milliseconds: 50));
        service.startRun(); // Try to start again

        expect(service.startTime, startTime); // Should be unchanged
      });
    });

    group('Pausing a run', () {
      test('should transition from running to paused', () {
        service.startRun();
        service.pauseRun();
        expect(service.state, RunState.paused);
        expect(service.isPaused, isTrue);
      });

      test('should not pause if not running', () {
        service.pauseRun();
        expect(service.state, RunState.idle);
      });

      test('should emit state change event', () async {
        service.startRun();

        expectLater(service.stateStream, emitsInOrder([RunState.paused]));

        service.pauseRun();
      });
    });

    group('Resuming a run', () {
      test('should transition from paused to running', () {
        service.startRun();
        service.pauseRun();
        service.resumeRun();
        expect(service.state, RunState.running);
        expect(service.isRunning, isTrue);
      });

      test('should not resume if not paused', () {
        service.startRun();
        service.resumeRun();
        expect(service.state, RunState.running); // Should still be running
      });

      test('should emit state change event', () async {
        service.startRun();
        service.pauseRun();

        expectLater(service.stateStream, emitsInOrder([RunState.running]));

        service.resumeRun();
      });
    });

    group('Stopping a run', () {
      test('should transition from running to finished', () {
        service.startRun();
        service.stopRun();
        expect(service.state, RunState.finished);
        expect(service.isFinished, isTrue);
      });

      test('should transition from paused to finished', () {
        service.startRun();
        service.pauseRun();
        service.stopRun();
        expect(service.state, RunState.finished);
      });

      test('should set end time', () {
        service.startRun();
        final before = DateTime.now();
        service.stopRun();
        final after = DateTime.now();

        expect(service.endTime, isNotNull);
        expect(
          service.endTime!.isAfter(before) ||
              service.endTime!.isAtSameMomentAs(before),
          isTrue,
        );
        expect(
          service.endTime!.isBefore(after) ||
              service.endTime!.isAtSameMomentAs(after),
          isTrue,
        );
      });

      test('should emit state change event', () async {
        service.startRun();

        expectLater(service.stateStream, emitsInOrder([RunState.finished]));

        service.stopRun();
      });

      test('should not stop if not running or paused', () {
        service.stopRun();
        expect(service.state, RunState.idle);
        expect(service.endTime, isNull);
      });
    });

    group('Resetting', () {
      test('should return to idle state', () {
        service.startRun();
        service.addRoutePoint(const LatLng(37.7749, -122.4194));
        service.stopRun();

        service.reset();

        expect(service.state, RunState.idle);
        expect(service.isIdle, isTrue);
      });

      test('should clear all data', () {
        service.startRun();
        service.addRoutePoint(const LatLng(37.7749, -122.4194));
        service.stopRun();

        service.reset();

        expect(service.routePoints, isEmpty);
        expect(service.startTime, isNull);
        expect(service.endTime, isNull);
        expect(service.elapsedTime, Duration.zero);
      });

      test('should emit state and route change events', () async {
        service.startRun();
        service.addRoutePoint(const LatLng(37.7749, -122.4194));

        expectLater(service.stateStream, emitsInOrder([RunState.idle]));

        expectLater(service.routeStream, emitsInOrder([isEmpty]));

        service.reset();
      });
    });

    group('Route tracking', () {
      test('should add points when running', () {
        service.startRun();

        final point1 = const LatLng(37.7749, -122.4194);
        final point2 = const LatLng(37.7750, -122.4195);

        service.addRoutePoint(point1);
        service.addRoutePoint(point2);

        expect(service.routePoints.length, 2);
        expect(service.routePoints[0], point1);
        expect(service.routePoints[1], point2);
      });

      test('should not add points when paused', () {
        service.startRun();
        service.addRoutePoint(const LatLng(37.7749, -122.4194));
        service.pauseRun();
        service.addRoutePoint(const LatLng(37.7750, -122.4195));

        expect(service.routePoints.length, 1);
      });

      test('should not add points when idle', () {
        service.addRoutePoint(const LatLng(37.7749, -122.4194));
        expect(service.routePoints, isEmpty);
      });

      test('should emit route updates when adding points', () async {
        service.startRun();

        final point = const LatLng(37.7749, -122.4194);

        expectLater(
          service.routeStream,
          emitsInOrder([
            [point],
          ]),
        );

        service.addRoutePoint(point);
      });

      test('should return unmodifiable list of route points', () {
        service.startRun();
        final points = service.routePoints;

        expect(() => points.add(const LatLng(0, 0)), throwsUnsupportedError);
      });
    });

    group('Elapsed time calculation', () {
      test('should calculate elapsed time during run', () async {
        service.startRun();
        await Future.delayed(const Duration(milliseconds: 100));
        service.stopRun();

        expect(service.elapsedTime.inMilliseconds, greaterThanOrEqualTo(100));
        expect(service.elapsedTime.inMilliseconds, lessThan(200));
      });

      test('should exclude paused duration', () async {
        service.startRun();
        await Future.delayed(const Duration(milliseconds: 50));
        service.pauseRun();
        await Future.delayed(
          const Duration(milliseconds: 100),
        ); // This should be excluded
        service.resumeRun();
        await Future.delayed(const Duration(milliseconds: 50));
        service.stopRun();

        // Should be approximately 100ms (50 + 50), not 200ms
        expect(service.elapsedTime.inMilliseconds, greaterThanOrEqualTo(100));
        expect(service.elapsedTime.inMilliseconds, lessThan(200));
      });

      test('should continue calculating while running', () async {
        service.startRun();
        await Future.delayed(const Duration(milliseconds: 50));

        final elapsed1 = service.elapsedTime;
        expect(elapsed1.inMilliseconds, greaterThanOrEqualTo(50));

        await Future.delayed(const Duration(milliseconds: 50));
        final elapsed2 = service.elapsedTime;
        expect(elapsed2.inMilliseconds, greaterThan(elapsed1.inMilliseconds));
      });
    });

    group('Stream management', () {
      test('should broadcast state changes to multiple listeners', () async {
        final listener1 = expectLater(
          service.stateStream,
          emitsInOrder([RunState.running, RunState.paused]),
        );

        final listener2 = expectLater(
          service.stateStream,
          emitsInOrder([RunState.running, RunState.paused]),
        );

        service.startRun();
        service.pauseRun();

        await listener1;
        await listener2;
      });

      test('should broadcast route updates to multiple listeners', () async {
        final point = const LatLng(37.7749, -122.4194);

        final listener1 = expectLater(
          service.routeStream,
          emitsInOrder([
            [point],
          ]),
        );

        final listener2 = expectLater(
          service.routeStream,
          emitsInOrder([
            [point],
          ]),
        );

        service.startRun();
        service.addRoutePoint(point);

        await listener1;
        await listener2;
      });
    });

    group('Edge cases', () {
      test('should handle rapid start/stop cycles', () {
        service.startRun();
        service.stopRun();
        service.startRun();
        service.stopRun();

        expect(service.state, RunState.finished);
      });

      test('should handle multiple pause/resume cycles', () async {
        service.startRun();
        await Future.delayed(const Duration(milliseconds: 10));

        service.pauseRun();
        await Future.delayed(const Duration(milliseconds: 10));
        service.resumeRun();

        await Future.delayed(const Duration(milliseconds: 10));
        service.pauseRun();
        await Future.delayed(const Duration(milliseconds: 10));
        service.resumeRun();

        expect(service.state, RunState.running);
      });

      test('should handle starting from finished state', () {
        service.startRun();
        service.stopRun();
        service.startRun();

        expect(service.state, RunState.running);
        expect(service.routePoints, isEmpty);
      });
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:run_tracker/services/run_tracker_service.dart';
import 'package:run_tracker/widgets/bottom_controls.dart';

void main() {
  group('BottomControls Widget', () {
    late RunTrackerService runTracker;

    setUp(() {
      runTracker = RunTrackerService();
    });

    tearDown(() async {
      await runTracker.dispose();
    });

    Widget createTestWidget({VoidCallback? onSheetCollapse}) {
      return MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              BottomControls(
                runTracker: runTracker,
                onSheetCollapse: onSheetCollapse,
              ),
            ],
          ),
        ),
      );
    }

    testWidgets('should display all three buttons', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Find activity mode button (left)
      expect(find.byIcon(Icons.directions_walk), findsOneWidget);

      // Find start/pause FAB (center)
      expect(find.byType(FloatingActionButton), findsOneWidget);

      // Find add route button (right)
      expect(find.byIcon(Icons.add_road), findsOneWidget);
    });

    testWidgets('should show play icon in idle state', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final fab = find.byType(FloatingActionButton);
      expect(fab, findsOneWidget);

      // Find the icon within the FAB
      final icon = find.descendant(
        of: fab,
        matching: find.byIcon(Icons.play_arrow),
      );
      expect(icon, findsOneWidget);
    });

    testWidgets('should show pause icon when running', (tester) async {
      await tester.pumpWidget(createTestWidget());

      runTracker.startRun();
      await tester.pump();

      final fab = find.byType(FloatingActionButton);
      final icon = find.descendant(of: fab, matching: find.byIcon(Icons.pause));
      expect(icon, findsOneWidget);
    });

    testWidgets('should show play icon when paused', (tester) async {
      await tester.pumpWidget(createTestWidget());

      runTracker.startRun();
      runTracker.pauseRun();
      await tester.pump();

      final fab = find.byType(FloatingActionButton);
      final icon = find.descendant(
        of: fab,
        matching: find.byIcon(Icons.play_arrow),
      );
      expect(icon, findsOneWidget);
    });

    testWidgets('should start run when FAB is tapped in idle state', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      expect(runTracker.state, RunState.idle);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();

      expect(runTracker.state, RunState.running);
    });

    testWidgets('should pause run when FAB is tapped while running', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      runTracker.startRun();
      await tester.pump();

      expect(runTracker.state, RunState.running);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();

      expect(runTracker.state, RunState.paused);
    });

    testWidgets('should resume run when FAB is tapped while paused', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      runTracker.startRun();
      runTracker.pauseRun();
      await tester.pump();

      expect(runTracker.state, RunState.paused);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();

      expect(runTracker.state, RunState.running);
    });

    testWidgets('should call onSheetCollapse when starting run', (
      tester,
    ) async {
      var collapsed = false;
      await tester.pumpWidget(
        createTestWidget(onSheetCollapse: () => collapsed = true),
      );

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();

      expect(collapsed, isTrue);
    });

    testWidgets('should not call onSheetCollapse when pausing', (tester) async {
      var collapsed = false;
      await tester.pumpWidget(
        createTestWidget(onSheetCollapse: () => collapsed = true),
      );

      runTracker.startRun();
      collapsed = false; // Reset after start
      await tester.pump();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();

      expect(collapsed, isFalse);
    });

    testWidgets('should disable side buttons when running', (tester) async {
      await tester.pumpWidget(createTestWidget());

      runTracker.startRun();
      await tester.pump();

      final activityButton = find.byIcon(Icons.directions_walk);
      final addRouteButton = find.byIcon(Icons.add_road);

      // Buttons should be present but disabled
      expect(activityButton, findsOneWidget);
      expect(addRouteButton, findsOneWidget);

      // Try tapping disabled buttons - they should not respond
      await tester.tap(activityButton);
      await tester.tap(addRouteButton);
      await tester.pump();

      // State should remain running
      expect(runTracker.state, RunState.running);
    });

    testWidgets('should enable side buttons when idle', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final activityButton = find.byIcon(Icons.directions_walk);
      final addRouteButton = find.byIcon(Icons.add_road);

      expect(activityButton, findsOneWidget);
      expect(addRouteButton, findsOneWidget);

      // Buttons should be enabled (able to tap)
      await tester.tap(activityButton);
      await tester.tap(addRouteButton);
      await tester.pump();
    });

    testWidgets('should have correct FAB color in idle state', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final fab = tester.widget<FloatingActionButton>(
        find.byType(FloatingActionButton),
      );

      expect(fab.backgroundColor, Colors.orange);
    });

    testWidgets('should have red FAB color when running', (tester) async {
      await tester.pumpWidget(createTestWidget());

      runTracker.startRun();
      await tester.pump();

      final fab = tester.widget<FloatingActionButton>(
        find.byType(FloatingActionButton),
      );

      expect(fab.backgroundColor, Colors.red);
    });

    testWidgets('should have orange FAB color when paused', (tester) async {
      await tester.pumpWidget(createTestWidget());

      runTracker.startRun();
      runTracker.pauseRun();
      await tester.pump();

      final fab = tester.widget<FloatingActionButton>(
        find.byType(FloatingActionButton),
      );

      expect(fab.backgroundColor, Colors.orange);
    });

    testWidgets('should update UI when state changes via stream', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      // Initial state - play icon
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
      expect(find.byIcon(Icons.pause), findsNothing);

      // Start run programmatically (not via tap)
      runTracker.startRun();
      await tester.pump();

      // Should update to pause icon
      expect(find.byIcon(Icons.pause), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow), findsNothing);

      // Pause run
      runTracker.pauseRun();
      await tester.pump();

      // Should update back to play icon
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
      expect(find.byIcon(Icons.pause), findsNothing);
    });



    testWidgets('should handle finished state like idle', (tester) async {
      await tester.pumpWidget(createTestWidget());

      runTracker.startRun();
      runTracker.stopRun();
      await tester.pump();

      expect(runTracker.state, RunState.finished);

      // Should show play icon
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);

      // Tapping should start a new run
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();

      expect(runTracker.state, RunState.running);
    });
  });
}

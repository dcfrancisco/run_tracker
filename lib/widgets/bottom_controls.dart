import 'package:flutter/material.dart';
import '../services/run_tracker_service.dart';

/// Fixed bottom controls bar anchored at the bottom of the screen.
class BottomControls extends StatelessWidget {
  final RunTrackerService runTracker;

  const BottomControls({super.key, required this.runTracker});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 110,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6),
        ],
      ),
      child: Row(
        children: [
          // Left spacer with activity button
          SizedBox(
            width: 64,
            child: IconButton(
              onPressed: () {},
              icon: Icon(Icons.directions_run, color: colorScheme.primary),
            ),
          ),

          // Center area: expanded and centered FAB (smaller)
          Expanded(
            child: Center(
              child: ValueListenableBuilder<RunState>(
                valueListenable: runTracker.state,
                builder: (context, state, _) {
                  final isRunning = state == RunState.running;
                  return FloatingActionButton.small(
                    heroTag: 'start_pause',
                    backgroundColor: Colors.deepOrange,
                    onPressed: () async {
                      if (state == RunState.idle ||
                          state == RunState.finished) {
                        await runTracker.startRun();
                      } else if (state == RunState.running) {
                        await runTracker.pauseRun();
                      } else if (state == RunState.paused) {
                        await runTracker.resumeRun();
                      }
                    },
                    child: Icon(
                      isRunning ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 20,
                    ),
                  );
                },
              ),
            ),
          ),

          // Right spacer with add route button
          SizedBox(
            width: 64,
            child: IconButton(
              onPressed: () {},
              icon: Icon(Icons.add_road, color: colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}

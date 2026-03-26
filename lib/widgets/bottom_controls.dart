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
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6)
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Activity mode button
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.directions_run, color: colorScheme.primary),
          ),

          // Start / Pause FAB (center)
          ValueListenableBuilder<RunState>(
            valueListenable: runTracker.state,
            builder: (context, state, _) {
              final isRunning = state == RunState.running;
              final isPaused = state == RunState.paused;
              return FloatingActionButton.large(
                heroTag: 'start_pause',
                backgroundColor: Colors.deepOrange,
                onPressed: () async {
                  if (state == RunState.idle || state == RunState.finished) {
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
                ),
              );
            },
          ),

          // Add Route button
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.add_road, color: colorScheme.primary),
          ),
        ],
      ),
    );
  }
}

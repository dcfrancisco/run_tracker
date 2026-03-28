import 'package:flutter/material.dart';
import '../services/run_tracker_service.dart';

/// Fixed bottom controls bar anchored at the bottom of the screen.
class BottomControls extends StatelessWidget {
  final RunTrackerService runTracker;
  final VoidCallback? onSheetCollapse;

  const BottomControls({
    super.key,
    required this.runTracker,
    this.onSheetCollapse,
  });

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
              icon: Icon(Icons.directions_bike, color: colorScheme.primary),
            ),
          ),

          // Center area: expanded and centered FAB (smaller)
          Expanded(
            child: Center(
              child: ValueListenableBuilder<RunState>(
                valueListenable: runTracker.state,
                builder: (context, state, _) {
                  final isRunning = state == RunState.running;
                  return FloatingActionButton(
                    heroTag: 'start_pause',
                    backgroundColor: _getButtonColor(state),
                    onPressed: () async {
                      if (state == RunState.idle ||
                          state == RunState.finished) {
                        await runTracker.startRun();
                        onSheetCollapse?.call();
                      } else if (state == RunState.running) {
                        await runTracker.pauseRun();
                      } else if (state == RunState.paused) {
                        await runTracker.resumeRun();
                      }
                    },
                    child: Icon(
                      isRunning ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 32,
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

  Color _getButtonColor(RunState state) {
    switch (state) {
      case RunState.running:
        return Colors.red;
      case RunState.idle:
      case RunState.paused:
      case RunState.finished:
      default:
        return Colors.orange;
    }
  }
}

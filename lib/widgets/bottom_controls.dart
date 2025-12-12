import 'package:flutter/material.dart';
import '../services/run_tracker_service.dart';

/// Fixed bottom control bar with activity mode, start/pause, and add route buttons.
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

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: StreamBuilder<RunState>(
              stream: runTracker.stateStream,
              initialData: runTracker.state,
              builder: (context, snapshot) {
                final state = snapshot.data ?? RunState.idle;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Activity mode button (left)
                    IconButton(
                      icon: const Icon(Icons.directions_walk),
                      iconSize: 28,
                      color: colorScheme.onSurface,
                      onPressed: state == RunState.idle
                          ? () {
                              // TODO: Show activity mode selector
                            }
                          : null,
                    ),

                    // Start / Pause FAB (center)
                    FloatingActionButton.large(
                      heroTag: 'start_pause_btn',
                      backgroundColor: _getButtonColor(state),
                      foregroundColor: Colors.white,
                      elevation: 4,
                      onPressed: () => _handleMainButtonPress(state),
                      child: Icon(_getButtonIcon(state), size: 32),
                    ),

                    // Add route button (right)
                    IconButton(
                      icon: const Icon(Icons.add_road),
                      iconSize: 28,
                      color: colorScheme.onSurface,
                      onPressed: state == RunState.idle
                          ? () {
                              // TODO: Show route selector
                            }
                          : null,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _handleMainButtonPress(RunState state) {
    switch (state) {
      case RunState.idle:
      case RunState.finished:
        runTracker.startRun();
        onSheetCollapse?.call();
        break;
      case RunState.running:
        runTracker.pauseRun();
        break;
      case RunState.paused:
        runTracker.resumeRun();
        break;
    }
  }

  IconData _getButtonIcon(RunState state) {
    switch (state) {
      case RunState.idle:
      case RunState.finished:
        return Icons.play_arrow;
      case RunState.running:
        return Icons.pause;
      case RunState.paused:
        return Icons.play_arrow;
    }
  }

  Color _getButtonColor(RunState state) {
    switch (state) {
      case RunState.idle:
      case RunState.finished:
      case RunState.paused:
        return Colors.orange;
      case RunState.running:
        return Colors.red;
    }
  }
}

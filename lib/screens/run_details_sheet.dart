import 'package:flutter/material.dart';
import '../services/run_tracker_service.dart';
import '../widgets/drag_handle.dart';

/// Draggable bottom sheet containing run details and live stats.
class RunDetailsSheet extends StatelessWidget {
  final DraggableScrollableController controller;
  final RunTrackerService runTracker;

  const RunDetailsSheet({
    super.key,
    required this.controller,
    required this.runTracker,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      controller: controller,
      expand: false,
      initialChildSize: 0.14,
      minChildSize: 0.14,
      maxChildSize: 0.45,
      builder: (context, scrollController) {
        return Container(
          margin: const EdgeInsets.only(bottom: 110),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const DragHandle(),
                  const SizedBox(height: 8),

                  // Live stats summary
                  StreamBuilder<RunState>(
                    stream: runTracker.stateStream,
                    initialData: runTracker.state,
                    builder: (context, snapshot) {
                      final elapsed = runTracker.elapsedTime;
                      final routePoints = runTracker.routePoints;

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _SummaryStatTile(
                            label: 'Distance',
                            value: '${routePoints.length * 0.005} km',
                          ),
                          _SummaryStatTile(
                            label: 'Time',
                            value: _formatDuration(elapsed),
                          ),
                          _SummaryStatTile(label: 'Pace', value: '0:00 /km'),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Details list
                  const _RunDetailsList(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

/// Individual stat tile for summary display.
class _SummaryStatTile extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryStatTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
      ],
    );
  }
}

/// Details list showing extended run metrics.
class _RunDetailsList extends StatelessWidget {
  const _RunDetailsList();

  @override
  Widget build(BuildContext context) {
    const items = [
      _DetailRow(title: 'Speed', value: '0.0 km/h'),
      _DetailRow(title: 'Elevation', value: '0 m'),
      _DetailRow(title: 'Calories', value: '0 kcal'),
      _DetailRow(title: 'Steps', value: '0'),
    ];

    return Column(
      children: [
        for (int i = 0; i < items.length; i++) ...[
          items[i],
          if (i < items.length - 1) const Divider(height: 16),
        ],
      ],
    );
  }
}

/// Individual detail row showing metric label and value.
class _DetailRow extends StatelessWidget {
  final String title;
  final String value;

  const _DetailRow({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

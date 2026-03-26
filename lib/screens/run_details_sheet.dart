import 'dart:async';

import 'package:flutter/material.dart';

import '../services/run_tracker_service.dart';

/// Bottom sheet containing run details and stats.
class RunDetailsSheet extends StatefulWidget {
  final DraggableScrollableController? controller;
  final RunTrackerService? runTracker;

  const RunDetailsSheet({super.key, this.controller, this.runTracker});

  @override
  State<RunDetailsSheet> createState() => _RunDetailsSheetState();
}

class _RunDetailsSheetState extends State<RunDetailsSheet> {
  late final DraggableScrollableController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? DraggableScrollableController();
    // Auto-collapse when a run starts
    widget.runTracker?.state.addListener(_onRunStateChanged);
    // Add controller listener for snapping
    _controller.addListener(_onSheetSizeChanged);
  }

  @override
  void dispose() {
    widget.runTracker?.state.removeListener(_onRunStateChanged);
    _controller.removeListener(_onSheetSizeChanged);
    _snapTimer?.cancel();
    super.dispose();
  }

  void _onRunStateChanged() {
    final state = widget.runTracker?.state.value;
    if (state == RunState.running) {
      // collapse to initial size
      _controller.animateTo(
        0.14,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Timer? _snapTimer;
  void _onSheetSizeChanged() {
    _snapTimer?.cancel();
    _snapTimer = Timer(const Duration(milliseconds: 200), () {
      final size = _controller.size;
      final mid = (0.14 + 0.45) / 2;
      if (size >= mid) {
        _controller.animateTo(
          0.45,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      } else {
        _controller.animateTo(
          0.14,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      controller: _controller,
      initialChildSize: 0.14,
      minChildSize: 0.14,
      maxChildSize: 0.45,
      builder: (context, scrollController) {
        return Container(
          margin: const EdgeInsets.only(bottom: 110),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8),
            ],
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 45,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: colorScheme.onSurface.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                // Summary stats row (live values)
                _LiveSummary(runTracker: widget.runTracker),
                const SizedBox(height: 24),

                // Details list
                const _RunDetailsList(),

                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
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

class _LiveSummary extends StatefulWidget {
  final RunTrackerService? runTracker;
  const _LiveSummary({this.runTracker});

  @override
  State<_LiveSummary> createState() => _LiveSummaryState();
}

class _LiveSummaryState extends State<_LiveSummary> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    widget.runTracker?.routePoints.addListener(_onDataChanged);
    widget.runTracker?.state.addListener(_onDataChanged);
    widget.runTracker?.stepCounter?.stepCount.addListener(_onDataChanged);
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  void _onDataChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.runTracker?.routePoints.removeListener(_onDataChanged);
    widget.runTracker?.state.removeListener(_onDataChanged);
    widget.runTracker?.stepCounter?.stepCount.removeListener(_onDataChanged);
    _ticker?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final rt = widget.runTracker;
    final distance = rt?.currentDistanceKm ?? 0.0;
    final duration = rt?.getActiveDuration() ?? Duration.zero;
    final pace = rt?.currentPaceMinPerKm ?? 0.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _SummaryStatTile(
          label: 'Distance',
          value: '${distance.toStringAsFixed(2)} km',
        ),
        _SummaryStatTile(label: 'Time', value: _formatDuration(duration)),
        _SummaryStatTile(
          label: 'Pace',
          value: pace > 0 ? '${pace.toStringAsFixed(2)} min/km' : '—',
        ),
      ],
    );
  }
}

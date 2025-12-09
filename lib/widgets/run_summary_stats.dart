import 'package:flutter/material.dart';

/// Top-level run stats display (Distance, Time, Pace).
class RunSummaryStats extends StatelessWidget {
  final double distanceKm;
  final String formattedTime;
  final String formattedPace;

  const RunSummaryStats({
    required this.distanceKm,
    required this.formattedTime,
    required this.formattedPace,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _StatTile(
          label: 'Distance',
          value: '${distanceKm.toStringAsFixed(2)} km',
        ),
        _StatTile(label: 'Time', value: formattedTime),
        _StatTile(label: 'Pace', value: formattedPace),
      ],
    );
  }
}

/// Individual stat tile.
class _StatTile extends StatelessWidget {
  final String label;
  final String value;

  const _StatTile({required this.label, required this.value});

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

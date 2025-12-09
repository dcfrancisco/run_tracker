import 'package:flutter/material.dart';

/// Reusable drag handle widget.
class DragHandle extends StatelessWidget {
  final double width;
  final double height;
  final EdgeInsets margin;

  const DragHandle({
    this.width = 45,
    this.height = 5,
    this.margin = const EdgeInsets.only(bottom: 16),
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Container(
        width: width,
        height: height,
        margin: margin,
        decoration: BoxDecoration(
          color: colorScheme.onSurface.withOpacity(0.25),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

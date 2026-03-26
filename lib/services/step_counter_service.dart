import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:pedometer/pedometer.dart';

/// Simple step counter service using the `pedometer` package.
class StepCounterService {
  final ValueNotifier<int> stepCount = ValueNotifier<int>(0);
  StreamSubscription<StepCount>? _sub;

  /// Start listening to step events.
  void start() {
    // Reset count to zero when starting a new session
    stepCount.value = 0;
    _sub = Pedometer.stepCountStream.listen(
      (StepCount event) {
        try {
          stepCount.value = event.steps;
        } catch (_) {}
      },
      onError: (_) {
        // ignore
      },
    );
  }

  /// Stop listening to step events.
  Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
  }

  void dispose() {
    _sub?.cancel();
    stepCount.dispose();
  }
}

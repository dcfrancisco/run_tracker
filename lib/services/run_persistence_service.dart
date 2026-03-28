import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../models/run_record.dart';

/// Simple persistence service that saves `RunRecord` JSON into a Hive box.
class RunPersistenceService {
  static const String boxName = 'runs_box';

  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<String>(boxName);
  }

  Future<void> saveRun(RunRecord record) async {
    final box = Hive.box<String>(boxName);
    final json = jsonEncode(record.toJson());
    await box.add(json);
  }

  List<RunRecord> loadAllRuns() {
    final box = Hive.box<String>(boxName);
    final records = <RunRecord>[];
    for (final val in box.values) {
      try {
        final map = jsonDecode(val) as Map<String, dynamic>;
        records.add(RunRecord.fromJson(map));
      } catch (_) {
        // ignore malformed entries
      }
    }
    return records;
  }

  Future<void> clearAll() async {
    final box = Hive.box<String>(boxName);
    await box.clear();
  }
}

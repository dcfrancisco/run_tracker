import 'package:flutter/material.dart';

import 'screens/map_view.dart';
import 'services/run_persistence_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local persistence (Hive) before running the app.
  final persistence = RunPersistenceService();
  await persistence.init();

  runApp(BottomSheetDemoApp(persistence: persistence));
}

class BottomSheetDemoApp extends StatelessWidget {
  final RunPersistenceService persistence;

  const BottomSheetDemoApp({super.key, required this.persistence});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Run Tracker Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: HomePage(persistence: persistence),
    );
  }
}

class HomePage extends StatefulWidget {
  final RunPersistenceService persistence;

  const HomePage({super.key, required this.persistence});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Run Tracker")),
      body: MapView(persistence: widget.persistence),
    );
  }
}

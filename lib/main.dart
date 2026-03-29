import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:run_tracker/l10n/app_localizations.dart';

import 'screens/map_view.dart';
import 'services/run_persistence_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock app to portrait orientations.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

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
      onGenerateTitle: (context) =>
          AppLocalizations.of(context)?.appTitle ?? 'Run Tracker Demo',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
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
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)?.runTrackerTitle ?? 'Run Tracker',
        ),
      ),
      body: MapView(persistence: widget.persistence),
    );
  }
}

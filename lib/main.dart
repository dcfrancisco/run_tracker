import 'package:flutter/material.dart';
import 'screens/map_view.dart';
import 'screens/run_details_sheet.dart';
import 'services/location_service.dart';
import 'services/run_tracker_service.dart';
import 'widgets/bottom_controls.dart';

void main() {
  runApp(const BottomSheetDemoApp());
}

class BottomSheetDemoApp extends StatelessWidget {
  const BottomSheetDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Run Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final LocationService _locationService;
  late final RunTrackerService _runTracker;
  late final DraggableScrollableController _sheetController;

  @override
  void initState() {
    super.initState();
    _locationService = LocationService();
    _runTracker = RunTrackerService();
    _sheetController = DraggableScrollableController();

    // Wire up location updates to route tracking
    _locationService.positionStream.listen((position) {
      if (_runTracker.isRunning) {
        _runTracker.addRoutePoint(position);
      }
    });
  }

  @override
  void dispose() {
    _locationService.dispose();
    _runTracker.dispose();
    _sheetController.dispose();
    super.dispose();
  }

  void _collapseSheet() {
    if (_sheetController.isAttached) {
      _sheetController.animateTo(
        0.14,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Full-screen map
          Positioned.fill(
            child: MapView(
              locationService: _locationService,
              runTracker: _runTracker,
            ),
          ),

          // Draggable stats sheet
          RunDetailsSheet(
            controller: _sheetController,
            runTracker: _runTracker,
          ),

          // Fixed bottom controls
          BottomControls(
            runTracker: _runTracker,
            onSheetCollapse: _collapseSheet,
          ),
        ],
      ),
    );
  }
}

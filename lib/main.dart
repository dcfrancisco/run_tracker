import 'package:flutter/material.dart';
import 'screens/map_view.dart';

void main() {
  runApp(const BottomSheetDemoApp());
}

class BottomSheetDemoApp extends StatelessWidget {
  const BottomSheetDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Run Tracker Demo',
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Run Tracker")),
      body: const MapView(),
    );
  }
}

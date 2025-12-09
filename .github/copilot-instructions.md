# GitHub Copilot Instructions — bottom_sheet_demo

Purpose: Help AI agents be productive in this Flutter codebase by capturing the current architecture, patterns, and workflows.

## Big Picture

- App structure is a single-screen Flutter app showing:
  - A full-screen map (OpenStreetMap via `flutter_map`).
  - A draggable bottom sheet with run-style stats.
- Material 3 theming with `colorSchemeSeed`; prefer `Theme.of(context).colorScheme` over hard-coded colors.

## Key Files

- `lib/main.dart`: App shell (Scaffold), `Stack` with the map and a `DraggableScrollableSheet` anchored to the bottom. Uses `FlutterMap` and `LatLng`.
- `lib/bottom_sheet_form.dart`: Stateless stats panel UI (drag handle, summary stat cards, details list). No form logic.
- `pubspec.yaml`: Declares `flutter_map` and `latlong2` dependencies; SDK constrained to `^3.9.2`.

## Core Patterns

- Draggable sheet anchored at bottom:
  ```dart
  DraggableScrollableSheet(
    expand: false,
    initialChildSize: 0.12, // starts at bottom
    minChildSize: 0.12,
    maxChildSize: 0.85,
    builder: (context, controller) => SafeArea(
      top: false,
      child: SingleChildScrollView(
        controller: controller,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: const BottomSheetForm(), // content stays stateless
      ),
    ),
  )
  ```
- Map via `flutter_map` (no API keys); keep it behind the sheet:
  ```dart
  FlutterMap(
    options: MapOptions(
      initialCenter: LatLng(37.7749, -122.4194),
      initialZoom: 12,
    ),
    children: [
      TileLayer(
        urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
        subdomains: ['a','b','c'],
        userAgentPackageName: 'bottom_sheet_demo',
      ),
    ],
  )
  ```
- Stats panel conventions (`BottomSheetForm`):
  - Keep as a `StatelessWidget` with a `Column` (drag handle, 3 compact stat cards, detail rows).
  - Use `colorScheme.surface` for backgrounds, `onSurface`/`onSurfaceVariant` for text.
  - Do not nest another `DraggableScrollableSheet` inside this widget.

## Developer Workflows

- Install deps and run:
  ```sh
  flutter pub get
  flutter run
  ```
- Lint/analyze and format:
  ```sh
  flutter analyze
  flutter format lib
  ```
- Tests:
  ```sh
  flutter test
  ```

## Platform Notes

- iOS: `ios/Runner/Info.plist`. If adding location features later, you must add `NSLocationWhenInUseUsageDescription` keys.
- Android: `android/app/src/main/AndroidManifest.xml`. `INTERNET` is included by default for Flutter; add location permissions if needed later.

## Extending Safely

- Snapping sheet: introduce `DraggableScrollableController` and snap between `[0.12, 0.35, 0.85]`.
- Map overlays: add `MarkerLayer` or `PolylineLayer` to `FlutterMap.children`.
- Theming: prefer `colorScheme` and `useMaterial3: true`; avoid raw `Colors.*` unless intentional.

If anything above becomes outdated (e.g., dependency changes, new screens), please update this file with concrete examples and the exact file paths involved.

---

# ✅ **COPILOT INSTRUCTIONS — RUN TRACKER APP**

## 📌 Project Goal

Build a Flutter-based **Run Tracker App** similar to Strava / Nike Run Club using:

- `flutter_map` + OpenStreetMap
- Live GPS tracking
- Real-time route polylines
- Step counter (pedometer)
- Speed, pace, distance & calorie calculation
- Local DB or Firebase storage for run history
- Auto-collapsing bottom sheet (inDrive-style)

The app must run on iOS and Android.

---

# 🏗️ Architecture Requirements

- Use **Flutter (Material 3)**
- Follow **Clean Architecture**:

  - `/services/` for GPS, pedometer, and tracking logic
  - `/models/` for RunRecord, settings, etc.
  - `/screens/` for main screens
  - `/widgets/` for UI components

- Code must be modular and easy to extend.

---

# 🌍 PHASE 1 — LIVE LOCATION TRACKING

### Requirements

- Use `geolocator` for GPS.
- Request permissions at startup.
- Listen to GPS stream with high accuracy.
- Update user's marker on map in real time.
- Store current position in `LatLng currentPosition`.

### What Copilot Should Generate

- A `LocationService` class that:

  - Requests permissions
  - Starts/stops a position stream
  - Streams `LatLng` updates to listeners

---

# ▶️ PHASE 2 — START / STOP RUN TRACKING LOGIC

### Requirements

- Add `RunState` enum: `idle, running, paused, finished`
- When run starts:

  - Clear previous routePoints
  - Start collecting GPS updates
  - Capture start time

- When run stops:

  - Stop collecting GPS
  - Capture end time
  - Compute summary

### What Copilot Should Generate

- `RunTrackerService` class
- Methods:

  - `startRun()`
  - `pauseRun()`
  - `resumeRun()`
  - `stopRun()`

- Maintain:

  - `List<LatLng> routePoints`
  - `DateTime startTime`
  - `DateTime endTime`

---

# 🧵 PHASE 3 — REALTIME POLYLINE DRAWING

### Requirements

- On every GPS update during running:

  - Append point to `routePoints`

- Display polyline via `flutter_map` PolylineLayer

### What Copilot Should Generate

A widget update that listens to route changes and redraws the polyline.

---

# 🚶 PHASE 4 — STEP COUNTER (PEDOMETER)

### Requirements

- Use `pedometer` package
- Listen to steps with `stepCountStream`
- Store steps in `int stepCount`
- Reset on startRun()

### What Copilot Should Generate

`StepCounterService`

- Method: `startStepMonitoring()`
- Method: `stopStepMonitoring()`
- Step listener callback.

---

# ⏱️ PHASE 5 — SPEED, PACE, DISTANCE & CALORIES

### Requirements

Copilot must always generate formulas:

#### Distance (km)

```
Use Haversine via package: latlong2.Distance().as()
Accumulated sum per GPS update.
```

#### Pace (min/km)

```
pace = durationMinutes / distanceKm
```

#### Speed (km/h)

```
speed = distanceKm / (durationHours)
```

#### Calories

```
calories = weightKg * distanceKm * 1.036
```

### What Copilot Should Generate

Utility class: `RunMetrics`

- `double calculateDistance(List<LatLng> points)`
- `double calculatePace(duration, distance)`
- `double calculateSpeed(duration, distance)`
- `double calculateCalories(weightKg, distance)`

---

# 💾 PHASE 6 — SAVE RUNS TO LOCAL DB (Hive) OR FIREBASE

### Requirements

Copilot must implement both options **but default to Hive**.

### Data Model (Copilot must use this)

```dart
class RunRecord {
  final List<LatLng> points;
  final double distanceKm;
  final double pace;
  final double speed;
  final double calories;
  final int steps;
  final DateTime date;
}
```

### What Copilot Should Generate

#### For Hive

- `RunRecordAdapter`
- Box: `"runs_box"`

#### For Firebase

Store:

```
points, distanceKm, pace, speed, calories, steps, date
```

---

# ⬇️ PHASE 7 — AUTO-COLLAPSING BOTTOM SHEET (IN-DRIVE STYLE)

### Requirements

- Use `DraggableScrollableController`
- Add two modes:

  - `collapsedHeight = 0.12`
  - `expandedHeight = 0.85`

- Collapse automatically when:

  - Run starts
  - Map is interacted with

- Expand when sheet dragged up.

### What Copilot Should Generate

Utility class:

```dart
class BottomSheetController {
  final DraggableScrollableController controller;

  void expand();
  void collapse();
}
```

---

# 🎨 UI REQUIREMENTS

- Follow Material 3
- All stats displayed in bottom sheet:

  - Distance
  - Pace
  - Time
  - Steps
  - Calories

- Colors must use `Theme.of(context).colorScheme`.

---

# 🔥 GENERAL INSTRUCTIONS FOR COPILOT

Copilot must follow these rules:

1. **Never write monolithic code.**
2. **Always break logic into services, models, and widgets.**
3. **Always generate null-safe Flutter code.**
4. **Always use descriptive class names.**
5. **Always comment code clearly.**
6. **Avoid deprecated APIs.**
7. **Use async/await properly.**

---

# 📌 OUTPUT EXPECTATION

When asked for code, Copilot must produce:

- Clean Dart code
- Modular structure
- Working implementation per phase
- No missing imports
- No deprecated APIs

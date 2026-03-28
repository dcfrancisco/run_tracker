
# 🏃 Run Tracker

A Strava/Nike Run Club–style Flutter app for run tracking, real-time GPS, and interactive map visualization.

## ✨ Features

- 🗺️ **Live Location Tracking** - Real-time GPS updates with high accuracy
- 📍 **Interactive Map** - OpenStreetMap integration with pinch/zoom support
- 🎯 **Smart Auto-Follow** - Automatically follows your position while running
- 🔄 **Re-center Button** - Quick button to jump back to your current location
- 📱 **Material 3 Design** - Modern UI with dynamic theming


## 🏗️ Architecture

Follows a strict 3-layer Stack UI:

1. Full-screen map (`flutter_map`)
2. Draggable stats sheet (`DraggableScrollableSheet`)
3. Fixed bottom controls (buttons)

**Project structure:**

```
lib/
 ├─ main.dart
 ├─ screens/
 │   ├─ map_view.dart
 │   ├─ run_details_sheet.dart
 ├─ widgets/
 │   ├─ bottom_controls.dart
 │   ├─ drag_handle.dart
 │   ├─ run_summary_stats.dart
 ├─ services/
 │   ├─ location_service.dart
 │   ├─ run_tracker_service.dart
 │   ├─ step_counter_service.dart
 ├─ models/
 │   ├─ run_record.dart
 └─ utils/
	 ├─ run_metrics.dart
```

See [ROADMAP.md](ROADMAP.md) and [.github/copilot-instructions.md](.github/copilot-instructions.md) for implementation phases and coding rules.

## 🚀 Getting Started

### Prerequisites

- Flutter SDK ^3.9.2
- Dart 3.9.2+
- Android Studio / Xcode for mobile development

### Installation

1. Clone the repository:
```bash
git clone https://github.com/dcfrancisco/run_tracker.git
cd run_tracker
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

### Build Release APK (Android)

```bash
flutter build apk --release
```

## 📦 Dependencies

- **flutter_map** `^7.0.2` - Interactive map widget with OpenStreetMap
- **latlong2** `^0.9.1` - Latitude/longitude calculations
- **geolocator** `^10.1.0` - GPS location services and permissions

## 🔑 Permissions

### Android
- `ACCESS_FINE_LOCATION` - High-accuracy GPS tracking
- `ACCESS_COARSE_LOCATION` - Network-based location
- `INTERNET` - Map tile loading

### iOS
- `NSLocationWhenInUseUsageDescription` - Location access while using app

## 🎮 How to Use

1. **Grant Location Permission** - Allow the app to access your location when prompted
2. **Start Tracking** - Your position appears as a blue marker on the map
3. **Explore the Map** - Pinch to zoom, drag to pan
4. **Re-center** - Tap the floating button to return to your current location

## 🛠️ Development

### Run Tests
```bash
flutter test
```

### Code Analysis
```bash
flutter analyze
```

### Format Code
```bash
dart format lib
```


## 🗺️ Roadmap

See [ROADMAP.md](ROADMAP.md) for detailed phases and features.

## 📄 License

This project is open source and available under the MIT License.

## 💖 Support

If you find this project helpful, consider buying me a coffee!

[![Buy Me A Coffee](https://img.shields.io/badge/Buy%20Me%20A%20Coffee-dcfrancisco-yellow.svg)](https://www.buymeacoffee.com/dcfrancisco)

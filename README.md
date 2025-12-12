# 🏃 Run Tracker

A Flutter-based run tracking app with real-time GPS tracking and interactive map visualization, similar to Strava and Nike Run Club.

## ✨ Features

- 🗺️ **Live Location Tracking** - Real-time GPS updates with high accuracy
- 📍 **Interactive Map** - OpenStreetMap integration with pinch/zoom support
- 🎯 **Smart Auto-Follow** - Automatically follows your position while running
- 🔄 **Re-center Button** - Quick button to jump back to your current location
- 📱 **Material 3 Design** - Modern UI with dynamic theming

## 🏗️ Architecture

Built following **Clean Architecture** principles:

```
lib/
├── main.dart              # App entry point
├── models/                # Data models (RunRecord, etc.)
├── screens/               # UI screens (MapView, etc.)
├── services/              # Business logic (LocationService)
└── widgets/               # Reusable UI components
```

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

- [ ] Start/Stop run tracking with polyline routes
- [ ] Step counter (pedometer integration)
- [ ] Speed, pace, distance calculations
- [ ] Calorie tracking
- [ ] Run history with local storage (Hive/Firebase)
- [ ] Auto-collapsing bottom sheet (inDrive-style)
- [ ] Run statistics and summaries

## 📄 License

This project is open source and available under the MIT License.

## 💖 Support

If you find this project helpful, consider buying me a coffee!

[![Buy Me A Coffee](https://img.shields.io/badge/Buy%20Me%20A%20Coffee-dcfrancisco-yellow.svg)](https://www.buymeacoffee.com/dcfrancisco)

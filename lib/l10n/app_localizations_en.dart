// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Run Tracker Demo';

  @override
  String get runTrackerTitle => 'Run Tracker';

  @override
  String get distance => 'Distance';

  @override
  String get time => 'Time';

  @override
  String get pace => 'Pace';

  @override
  String get speed => 'Speed';

  @override
  String get calories => 'Calories';

  @override
  String get steps => 'Steps';

  @override
  String get elevation => 'Elevation';

  @override
  String get kmPerHour => 'km/h';

  @override
  String get minPerKm => 'min/km';

  @override
  String get kcal => 'kcal';
}

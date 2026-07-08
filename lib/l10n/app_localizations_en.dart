// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Zero Waste Chef🍏';

  @override
  String get fridgeTab => 'Fridge';

  @override
  String get favoritesTab => 'Favorites';

  @override
  String get profileTab => 'Profile';

  @override
  String get addIngredientHint => 'Example: Spinach, Cheese...';

  @override
  String get emptyFridge => 'Your fridge is empty 🏜';
}

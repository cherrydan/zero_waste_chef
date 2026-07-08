// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Chef Zero Waste 🍏';

  @override
  String get fridgeTab => 'Nevera';

  @override
  String get favoritesTab => 'Favoritos';

  @override
  String get profileTab => 'Perfil';

  @override
  String get addIngredientHint => 'Ejemplo: Espinacas, Queso...';

  @override
  String get emptyFridge => 'La nevera está vacía 🏜';
}

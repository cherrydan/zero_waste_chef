// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Zero Waste Chef 🍏';

  @override
  String get fridgeTab => 'Холодильник';

  @override
  String get favoritesTab => 'Избранное';

  @override
  String get profileTab => 'Профиль';

  @override
  String get addIngredientHint => 'Например: Шпинат, Сыр...';

  @override
  String get emptyFridge => 'В холодильнике пока пусто 🏜';
}

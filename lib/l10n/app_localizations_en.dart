// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Zero Waste Chef';

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

  @override
  String get quickSelectTitle => 'Quick Select: ⚡️';

  @override
  String get dietTypeTitle => 'Diet Type: 🥗';

  @override
  String get portionsTitle => 'Portions:';

  @override
  String get generateButton => 'Generate Menu (AI)';

  @override
  String get profileScreenTitle => 'User Profile';

  @override
  String get logoutButton => 'Log out';

  @override
  String get ecoStatus => 'Eco Status';

  @override
  String get clearAllDialogTitle => 'Clear all?';

  @override
  String get clearAllDialogContent =>
      'Are you sure you want to delete all products from the fridge? This action cannot be undone.';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get deleteAllButton => 'Delete all';

  @override
  String get popTomatoes => 'Tomatoes';

  @override
  String get popChicken => 'Chicken';

  @override
  String get popFeta => 'Feta';

  @override
  String get popEggs => 'Eggs';

  @override
  String get popMeat => 'Meat';

  @override
  String get popSeafood => 'Seafood';

  @override
  String get popMilk => 'Milk';

  @override
  String expiredDaysText(int days) {
    return 'EXPIRED BY $days DAYS! ⚠️';
  }

  @override
  String bestBefore(String date) {
    return 'Best before: $date';
  }

  @override
  String get dietRegular => 'Regular';

  @override
  String get dietMediterranean => 'Mediterranean';

  @override
  String get dietVegetarian => 'Vegetarian';
}

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

  @override
  String get quickSelectTitle => 'Быстрый выбор: ⚡️';

  @override
  String get dietTypeTitle => 'Тип диеты: 🥗';

  @override
  String get portionsTitle => 'Порций:';

  @override
  String get generateButton => 'Сгенерировать меню (AI)';

  @override
  String get profileScreenTitle => 'Профиль пользователя';

  @override
  String get logoutButton => 'Выйти из аккаунта';

  @override
  String get ecoStatus => 'Эко-статус';

  @override
  String get clearAllDialogTitle => 'Очистить всё? 🗑️';

  @override
  String get clearAllDialogContent =>
      'Вы уверены, что хотите удалить все продукты из холодильника? Это действие нельзя отменить.';

  @override
  String get cancelButton => 'Отмена';

  @override
  String get deleteAllButton => 'Удалить всё';

  @override
  String get popTomatoes => 'Помидоры';

  @override
  String get popChicken => 'Курица';

  @override
  String get popFeta => 'Сыр Фета';

  @override
  String get popEggs => 'Яйца';

  @override
  String get popMeat => 'Мясо';

  @override
  String get popSeafood => 'Морепродукты';

  @override
  String get popMilk => 'Молоко';

  @override
  String expiredDaysText(int days) {
    return 'ПРОСРОЧЕНО НА $days ДН.! ⚠️';
  }

  @override
  String bestBefore(String date) {
    return 'Годен до: $date';
  }

  @override
  String get dietRegular => 'Обычная';

  @override
  String get dietMediterranean => 'Средиземноморская';

  @override
  String get dietVegetarian => 'Вегетарианская';
}

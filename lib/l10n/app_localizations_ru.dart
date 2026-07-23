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
  String get clearAllButton => 'Очистить всё';

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
  String get ecoStatus => 'Эко-статус';

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
  String get dietRegular => 'Обычная';

  @override
  String get dietMediterranean => 'Средиземноморская';

  @override
  String get dietVegetarian => 'Вегетарианская';

  @override
  String get recipeTitle => 'Рецепт';

  @override
  String get shoppingList => 'Список покупок';

  @override
  String get steps => 'Шаги приготовления';

  @override
  String get shareRecipe => 'Поделиться';

  @override
  String get aiThinking => 'Шеф-повар думает...🧑‍🍳';

  @override
  String get copySuccess => 'Скопировано!';

  @override
  String expiredDaysText(int days) {
    return 'ПРОСРОЧЕНО НА $days ДН.! ⚠️';
  }

  @override
  String bestBefore(String date) {
    return 'Годен до: $date';
  }

  @override
  String get ingredientExpiredTag =>
      ' (ПОМЕТКА: ПРОСРОЧЕН! Использовать С ОСТОРОЖНОСТЬЮ, только после глубокой ТЕРМИЧЕСКОЙ ОБРАБОТКИ. Для мяса/рыбы - ЗАПРЕТ!)';

  @override
  String get ingredientUrgentTag =>
      ' (ПОМЕТКА: СРОЧНО! Истекает срок годности, использовать ОБЯЗАТЕЛЬНО!)';

  @override
  String aiRecipePrompt(int portions, String ingredientsList, String dietType) {
    return 'Приготовь блюдо строго на $portions порции(й) из следующих продуктов: $ingredientsList. ЖЕСТКИЕ ПРАВИЛА БЕЗОПАСНОСТИ: 1. ПРОДУКТЫ С ПОМЕТКОЙ (СРОЧНО!): ДОЛЖНЫ быть использованы в рецепте в первую очередь, чтобы предотвратить порчу. 2. ПРОДУКТЫ С ПОМЕТКОЙ (ПРОСРОЧЕН!): Если это мясо, птица, рыба, морепродукты или грибы — КАТЕГОРИЧЕСКИ ЗАПРЕЩЕНО использовать их в рецепте. Предложи пользователю безопасно утилизировать их. Если это молочные продукты, овощи, фрукты, хлеб и т.п. — использовать можно ТОЛЬКО при условии ГЛУБОКОЙ ТЕРМИЧЕСКОЙ ОБРАБОТКИ (варка, тушение, выпечка при высокой температуре). Не предлагать салаты или блюда без термической обработки! Нельзя предлагать просроченные продукты без термической обработки! 3. Добавь не больше 2 дешевых ингредиентов, если это необходимо. 4. Рецепт должен строго соответствовать диете: $dietType. Ответ верни СТРОГО в формате JSON с ключами: \'recipe_name\' (строка), \'shopping_list\' (массив строк), \'steps\' (массив строк).';
  }

  @override
  String get cloudDataLoaded => 'Данные успешно загружены из облака! ☁️';

  @override
  String get offlineModeCloudError =>
      'Офлайн-режим: Не удалось загрузить из облака. Пробуем локальную память...';

  @override
  String get localDataLoaded => 'Данные загружены локально из памяти. 💾';

  @override
  String get recipeCopied => 'Рецепт скопирован в буфер обмена!';

  @override
  String get copyError => 'Не удалось скопировать рецепт. Попробуйте еще раз.';

  @override
  String get aiErrorFallback =>
      'Упс! Что-то пошло не так при генерации рецепта. Попробуйте еще раз!';

  @override
  String get disclaimerText =>
      'Дисклеймер: ИИ предлагает варианты рецептов на основе ваших продуктов, но не оценивает их реальную свежесть. Всегда проверяйте запах, вид и срок годности ингредиентов самостоятельно перед употреблением. Разработчики не несут ответственности за возможные пищевые расстройства.';

  @override
  String get favoritesTitle => 'Мои рецепты ❤️';

  @override
  String get noSavedRecipes => 'Пока нет сохраненных рецептов';

  @override
  String recipeStepsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count шагов',
      few: '$count шага',
      one: '$count шаг',
    );
    return '$_temp0';
  }

  @override
  String get loginSlogan => 'Готовь с умом, спасай планету 🍏';

  @override
  String get googleSignIn => 'Войти через Google';

  @override
  String freeGenerations(Object current, Object max) {
    return 'Бесплатных генераций сегодня: $current / $max';
  }

  @override
  String get paywallTitle => 'Перейти на Premium ⭐️';

  @override
  String get paywallSubtitle => 'Раскройте весь потенциал Zero Waste Chef';

  @override
  String get featureUnlimited => 'Безлимитная генерация рецептов ИИ';

  @override
  String get featureFamily => 'Семейный холодильник (скоро)';

  @override
  String get featureSupport => 'Поддержка эко-разработки проекта';

  @override
  String get premiumPrice => '299 ₽ / месяц';

  @override
  String get subscribeButton => 'Получить Premium доступ';

  @override
  String get restorePurchases => 'Восстановить покупки';

  @override
  String get paymentFailed =>
      'Покупка не удалась или была отменена. Пожалуйста, попробуйте еще раз.';
}

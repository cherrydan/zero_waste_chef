// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Zero Waste Chef 🍏';

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
  String get clearAllButton => 'Clear all';

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
  String get ecoStatus => 'Eco Status';

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
  String get dietRegular => 'Regular';

  @override
  String get dietMediterranean => 'Mediterranean';

  @override
  String get dietVegetarian => 'Vegetarian';

  @override
  String get recipeTitle => 'Recipe';

  @override
  String get shoppingList => 'Shopping List';

  @override
  String get steps => 'Steps';

  @override
  String get shareRecipe => 'Share Recipe';

  @override
  String get aiThinking => 'Chef is thinking...🧑‍🍳';

  @override
  String get copySuccess => 'Copied to clipboard!';

  @override
  String expiredDaysText(int days) {
    return 'EXPIRED BY $days DAYS! ⚠️';
  }

  @override
  String bestBefore(String date) {
    return 'Best before: $date';
  }

  @override
  String get ingredientExpiredTag =>
      ' (NOTE: EXPIRED! Use WITH CAUTION, only after deep THERMAL PROCESSING. For meat/fish - FORBIDDEN!)';

  @override
  String get ingredientUrgentTag =>
      ' (NOTE: URGENT! Expiring soon, MUST be used!)';

  @override
  String aiRecipePrompt(int portions, String ingredientsList, String dietType) {
    return 'Prepare a dish strictly for $portions servings from the following ingredients: $ingredientsList. STRICT SAFETY RULES: 1. PRODUCTS MARKED AS (URGENT!): MUST be used in the recipe first to prevent spoilage. 2. PRODUCTS MARKED AS (EXPIRED!): If it\'s meat, poultry, fish, seafood or mushrooms - STRICTLY FORBIDDEN to use in the recipe. Suggest the user safely dispose of them. If it\'s dairy products, vegetables, fruits, bread, etc. - can only be used under strict THERMAL PROCESSING (boiling, stewing, baking at high temperature). Do not suggest salads or dishes without thermal processing! Do not offer expired products without thermal processing! 3. Add no more than 2 cheap ingredients if necessary. 4. The recipe must strictly adhere to the diet: $dietType. Return the answer STRICTLY in JSON format with keys: \'recipe_name\' (string), \'shopping_list\' (array of strings), \'steps\' (array of strings).';
  }

  @override
  String get cloudDataLoaded => 'Data successfully loaded from cloud! ☁️';

  @override
  String get offlineModeCloudError =>
      'Offline mode: Failed to load from cloud. Trying local memory...';

  @override
  String get localDataLoaded =>
      'Data loaded locally from SharedPreferences. 💾';

  @override
  String get recipeCopied => 'Recipe copied to clipboard!';

  @override
  String get copyError => 'Failed to copy recipe. Please try again.';

  @override
  String get aiErrorFallback =>
      'Oops! Something went wrong while generating the recipe. Please try again!';

  @override
  String get disclaimerText =>
      'Disclaimer: AI suggests recipe options based on your ingredients, but does not assess their actual freshness. Always check the smell, appearance, and expiration date of ingredients yourself before consumption. Developers are not responsible for possible foodborne illnesses.';

  @override
  String get favoritesTitle => 'My Recipes ❤️';

  @override
  String get noSavedRecipes => 'No saved recipes yet';

  @override
  String recipeStepsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count steps',
      one: '1 step',
    );
    return '$_temp0';
  }

  @override
  String get loginSlogan => 'Cook smart, save the planet 🍏';

  @override
  String get googleSignIn => 'Sign in with Google';

  @override
  String freeGenerations(Object current, Object max) {
    return 'Free generations today: $current / $max';
  }
}

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('ru')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Zero Waste Chef 🍏'**
  String get appTitle;

  /// No description provided for @fridgeTab.
  ///
  /// In en, this message translates to:
  /// **'Fridge'**
  String get fridgeTab;

  /// No description provided for @favoritesTab.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favoritesTab;

  /// No description provided for @profileTab.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTab;

  /// No description provided for @addIngredientHint.
  ///
  /// In en, this message translates to:
  /// **'Example: Spinach, Cheese...'**
  String get addIngredientHint;

  /// No description provided for @emptyFridge.
  ///
  /// In en, this message translates to:
  /// **'Your fridge is empty 🏜'**
  String get emptyFridge;

  /// No description provided for @quickSelectTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick Select: ⚡️'**
  String get quickSelectTitle;

  /// No description provided for @dietTypeTitle.
  ///
  /// In en, this message translates to:
  /// **'Diet Type: 🥗'**
  String get dietTypeTitle;

  /// No description provided for @portionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Portions:'**
  String get portionsTitle;

  /// No description provided for @generateButton.
  ///
  /// In en, this message translates to:
  /// **'Generate Menu (AI)'**
  String get generateButton;

  /// No description provided for @profileScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'User Profile'**
  String get profileScreenTitle;

  /// No description provided for @logoutButton.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logoutButton;

  /// No description provided for @clearAllButton.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get clearAllButton;

  /// No description provided for @clearAllDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear all?'**
  String get clearAllDialogTitle;

  /// No description provided for @clearAllDialogContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete all products from the fridge? This action cannot be undone.'**
  String get clearAllDialogContent;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @deleteAllButton.
  ///
  /// In en, this message translates to:
  /// **'Delete all'**
  String get deleteAllButton;

  /// No description provided for @ecoStatus.
  ///
  /// In en, this message translates to:
  /// **'Eco Status'**
  String get ecoStatus;

  /// No description provided for @popTomatoes.
  ///
  /// In en, this message translates to:
  /// **'Tomatoes'**
  String get popTomatoes;

  /// No description provided for @popChicken.
  ///
  /// In en, this message translates to:
  /// **'Chicken'**
  String get popChicken;

  /// No description provided for @popFeta.
  ///
  /// In en, this message translates to:
  /// **'Feta'**
  String get popFeta;

  /// No description provided for @popEggs.
  ///
  /// In en, this message translates to:
  /// **'Eggs'**
  String get popEggs;

  /// No description provided for @popMeat.
  ///
  /// In en, this message translates to:
  /// **'Meat'**
  String get popMeat;

  /// No description provided for @popSeafood.
  ///
  /// In en, this message translates to:
  /// **'Seafood'**
  String get popSeafood;

  /// No description provided for @popMilk.
  ///
  /// In en, this message translates to:
  /// **'Milk'**
  String get popMilk;

  /// No description provided for @dietRegular.
  ///
  /// In en, this message translates to:
  /// **'Regular'**
  String get dietRegular;

  /// No description provided for @dietMediterranean.
  ///
  /// In en, this message translates to:
  /// **'Mediterranean'**
  String get dietMediterranean;

  /// No description provided for @dietVegetarian.
  ///
  /// In en, this message translates to:
  /// **'Vegetarian'**
  String get dietVegetarian;

  /// No description provided for @recipeTitle.
  ///
  /// In en, this message translates to:
  /// **'Recipe'**
  String get recipeTitle;

  /// No description provided for @shoppingList.
  ///
  /// In en, this message translates to:
  /// **'Shopping List'**
  String get shoppingList;

  /// No description provided for @steps.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get steps;

  /// No description provided for @shareRecipe.
  ///
  /// In en, this message translates to:
  /// **'Share Recipe'**
  String get shareRecipe;

  /// No description provided for @aiThinking.
  ///
  /// In en, this message translates to:
  /// **'Chef is thinking...🧑‍🍳'**
  String get aiThinking;

  /// No description provided for @copySuccess.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard!'**
  String get copySuccess;

  /// No description provided for @expiredDaysText.
  ///
  /// In en, this message translates to:
  /// **'EXPIRED BY {days} DAYS! ⚠️'**
  String expiredDaysText(int days);

  /// No description provided for @bestBefore.
  ///
  /// In en, this message translates to:
  /// **'Best before: {date}'**
  String bestBefore(String date);

  /// No description provided for @ingredientExpiredTag.
  ///
  /// In en, this message translates to:
  /// **' (NOTE: EXPIRED! Use WITH CAUTION, only after deep THERMAL PROCESSING. For meat/fish - FORBIDDEN!)'**
  String get ingredientExpiredTag;

  /// No description provided for @ingredientUrgentTag.
  ///
  /// In en, this message translates to:
  /// **' (NOTE: URGENT! Expiring soon, MUST be used!)'**
  String get ingredientUrgentTag;

  /// OpenAI prompt with safe rules
  ///
  /// In en, this message translates to:
  /// **'Prepare a dish strictly for {portions} servings from the following ingredients: {ingredientsList}. STRICT SAFETY RULES: 1. PRODUCTS MARKED AS (URGENT!): MUST be used in the recipe first to prevent spoilage. 2. PRODUCTS MARKED AS (EXPIRED!): If it\'s meat, poultry, fish, seafood or mushrooms - STRICTLY FORBIDDEN to use in the recipe. Suggest the user safely dispose of them. If it\'s dairy products, vegetables, fruits, bread, etc. - can only be used under strict THERMAL PROCESSING (boiling, stewing, baking at high temperature). Do not suggest salads or dishes without thermal processing! Do not offer expired products without thermal processing! 3. Add no more than 2 cheap ingredients if necessary. 4. The recipe must strictly adhere to the diet: {dietType}. Return the answer STRICTLY in JSON format with keys: \'recipe_name\' (string), \'shopping_list\' (array of strings), \'steps\' (array of strings).'**
  String aiRecipePrompt(int portions, String ingredientsList, String dietType);

  /// No description provided for @cloudDataLoaded.
  ///
  /// In en, this message translates to:
  /// **'Data successfully loaded from cloud! ☁️'**
  String get cloudDataLoaded;

  /// No description provided for @offlineModeCloudError.
  ///
  /// In en, this message translates to:
  /// **'Offline mode: Failed to load from cloud. Trying local memory...'**
  String get offlineModeCloudError;

  /// No description provided for @localDataLoaded.
  ///
  /// In en, this message translates to:
  /// **'Data loaded locally from SharedPreferences. 💾'**
  String get localDataLoaded;

  /// No description provided for @recipeCopied.
  ///
  /// In en, this message translates to:
  /// **'Recipe copied to clipboard!'**
  String get recipeCopied;

  /// No description provided for @copyError.
  ///
  /// In en, this message translates to:
  /// **'Failed to copy recipe. Please try again.'**
  String get copyError;

  /// No description provided for @aiErrorFallback.
  ///
  /// In en, this message translates to:
  /// **'Oops! Something went wrong while generating the recipe. Please try again!'**
  String get aiErrorFallback;

  /// No description provided for @disclaimerText.
  ///
  /// In en, this message translates to:
  /// **'Disclaimer: AI suggests recipe options based on your ingredients, but does not assess their actual freshness. Always check the smell, appearance, and expiration date of ingredients yourself before consumption. Developers are not responsible for possible foodborne illnesses.'**
  String get disclaimerText;

  /// No description provided for @favoritesTitle.
  ///
  /// In en, this message translates to:
  /// **'My Recipes ❤️'**
  String get favoritesTitle;

  /// No description provided for @noSavedRecipes.
  ///
  /// In en, this message translates to:
  /// **'No saved recipes yet'**
  String get noSavedRecipes;

  /// No description provided for @recipeStepsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 step} other{{count} steps}}'**
  String recipeStepsCount(num count);

  /// No description provided for @loginSlogan.
  ///
  /// In en, this message translates to:
  /// **'Cook smart, save the planet 🍏'**
  String get loginSlogan;

  /// No description provided for @googleSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get googleSignIn;

  /// No description provided for @freeGenerations.
  ///
  /// In en, this message translates to:
  /// **'Free generations today: {current} / {max}'**
  String freeGenerations(Object current, Object max);

  /// No description provided for @paywallTitle.
  ///
  /// In en, this message translates to:
  /// **'Go Premium ⭐️'**
  String get paywallTitle;

  /// No description provided for @paywallSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock the full potential of Zero Waste Chef'**
  String get paywallSubtitle;

  /// No description provided for @featureUnlimited.
  ///
  /// In en, this message translates to:
  /// **'Unlimited AI menu generations'**
  String get featureUnlimited;

  /// No description provided for @featureFamily.
  ///
  /// In en, this message translates to:
  /// **'Family Fridge sync (coming soon)'**
  String get featureFamily;

  /// No description provided for @featureSupport.
  ///
  /// In en, this message translates to:
  /// **'Support eco-friendly development'**
  String get featureSupport;

  /// No description provided for @premiumPrice.
  ///
  /// In en, this message translates to:
  /// **'\$4.99 / month'**
  String get premiumPrice;

  /// No description provided for @subscribeButton.
  ///
  /// In en, this message translates to:
  /// **'Unlock Premium Access'**
  String get subscribeButton;

  /// No description provided for @restorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get restorePurchases;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}

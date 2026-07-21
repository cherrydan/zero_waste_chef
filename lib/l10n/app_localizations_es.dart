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

  @override
  String get quickSelectTitle => 'Selección rápida: ⚡️';

  @override
  String get dietTypeTitle => 'Tipo de dieta: 🥗';

  @override
  String get portionsTitle => 'Porciones:';

  @override
  String get generateButton => 'Generar Menú (IA)';

  @override
  String get profileScreenTitle => 'Perfil de usuario';

  @override
  String get logoutButton => 'Cerrar sesión';

  @override
  String get clearAllButton => 'Limpiar todo';

  @override
  String get clearAllDialogTitle => '¿Limpiar todo? 🗑️';

  @override
  String get clearAllDialogContent =>
      '¿Está seguro de que desea eliminar todos los productos de la nevera? Esta acción no se puede deshacer.';

  @override
  String get cancelButton => 'Cancelar';

  @override
  String get deleteAllButton => 'Eliminar todo';

  @override
  String get ecoStatus => 'Estado ecológico';

  @override
  String get popTomatoes => 'Tomates';

  @override
  String get popChicken => 'Pollo';

  @override
  String get popFeta => 'Queso Feta';

  @override
  String get popEggs => 'Huevos';

  @override
  String get popMeat => 'Carne';

  @override
  String get popSeafood => 'Mariscos';

  @override
  String get popMilk => 'Leche';

  @override
  String get dietRegular => 'Normal';

  @override
  String get dietMediterranean => 'Mediterránea';

  @override
  String get dietVegetarian => 'Vegetariana';

  @override
  String get recipeTitle => 'Receta';

  @override
  String get shoppingList => 'Lista de la compra';

  @override
  String get steps => 'Pasos';

  @override
  String get shareRecipe => 'Compartir';

  @override
  String get aiThinking => 'El chef está pensando...🧑‍🍳';

  @override
  String get copySuccess => '¡Copiado al portapapeles!';

  @override
  String expiredDaysText(int days) {
    return '¡CADUCADO POR $days DÍAS! ⚠️';
  }

  @override
  String bestBefore(String date) {
    return 'Consumir antes de: $date';
  }

  @override
  String get ingredientExpiredTag =>
      ' (NOTA: ¡CADUCADO! Usar CON PRECAUCIÓN, solo después de un PROCESAMIENTO TÉRMICO profundo. ¡Para carne/pescado - PROHIBIDO!)';

  @override
  String get ingredientUrgentTag =>
      ' (NOTA: ¡URGENTE! Caduca pronto, ¡DEBE usarse!)';

  @override
  String aiRecipePrompt(int portions, String ingredientsList, String dietType) {
    return 'Prepara un plato estrictamente para $portions raciones con los siguientes ingredientes: $ingredientsList. REGLAS ESTRICTAS DE SEGURIDAD: 1. PRODUCTOS MARCADOS COMO (¡URGENTE!): DEBEN utilizarse primero en la receta para evitar su deterioro. 2. PRODUCTOS MARCADOS COMO (¡CADUCADO!): Si es carne, aves, pescado, marisco o champiñones - ESTRICTAMENTE PROHIBIDO utilizarlos en la receta. Sugiera al usuario que los deseche de forma segura. Si son productos lácteos, verduras, frutas, pan, etc. - solo se pueden utilizar bajo un ESTRICTO PROCESAMIENTO TÉRMICO (hervir, estofar, hornear a alta temperatura). ¡No sugiera ensaladas o platos sin procesamiento térmico! ¡No ofrezca productos caducados sin procesamiento térmico! 3. Añada no más de 2 ingredientes baratos si es necesario. 4. La receta debe ajustarse a la dieta: $dietType. Devuelve la respuesta ESTRICTAMENTE en formato JSON con las claves: \'recipe_name\' (string), \'shopping_list\' (matriz de cadenas), \'steps\' (matriz de cadenas).';
  }

  @override
  String get cloudDataLoaded => '¡Datos cargados con éxito desde la nube! ☁️';

  @override
  String get offlineModeCloudError =>
      'Modo sin conexión: Fallo al cargar desde la nube. Intentando memoria local...';

  @override
  String get localDataLoaded =>
      'Datos cargados localmente desde la memoria. 💾';

  @override
  String get recipeCopied => '¡Receta copiada al portapapeles!';

  @override
  String get copyError =>
      'No se pudo copiar la receta. Por favor, inténtelo de nuevo.';

  @override
  String get aiErrorFallback =>
      '¡Ups! Algo salió mal al generar la receta. ¡Por favor, inténtelo de nuevo!';

  @override
  String get disclaimerText =>
      'Descargo de responsabilidad: La IA sugiere opciones de recetas basadas en sus ingredientes, pero no evalúa su frescura real. Siempre verifique el olor, la apariencia y la fecha de caducidad de los ingredientes usted mismo antes de consumirlos. Los desarrolladores no son responsables de posibles enfermedades transmitidas por los alimentos.';

  @override
  String get favoritesTitle => 'Mis recetas ❤️';

  @override
  String get noSavedRecipes => 'Aún no hay recetas guardadas';

  @override
  String recipeStepsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pasos',
      one: '1 paso',
    );
    return '$_temp0';
  }

  @override
  String get loginSlogan => 'Cocina con inteligencia, salva el planeta 🍏';

  @override
  String get googleSignIn => 'Iniciar sesión con Google';

  @override
  String freeGenerations(Object current, Object max) {
    return 'Generaciones gratuitas hoy: $current / $max';
  }

  @override
  String get paywallTitle => 'Hazte Premium ⭐️';

  @override
  String get paywallSubtitle =>
      'Desbloquea todo el potencial de Chef Zero Waste';

  @override
  String get featureUnlimited => 'Generación ilimitada de recetas con IA';

  @override
  String get featureFamily => 'Sincronización familiar (próximamente)';

  @override
  String get featureSupport => 'Apoya el desarrollo ecológico del proyecto';

  @override
  String get premiumPrice => '4,99 € / mes';

  @override
  String get subscribeButton => 'Obtener acceso Premium';

  @override
  String get restorePurchases => 'Restaurar compras';
}

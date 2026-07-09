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
  String get ecoStatus => 'Estado ecológico';

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
  String expiredDaysText(int days) {
    return '¡CADUCADO POR $days DÍAS! ⚠️';
  }

  @override
  String bestBefore(String date) {
    return 'Consumir antes de: $date';
  }

  @override
  String get dietRegular => 'Normal';

  @override
  String get dietMediterranean => 'Mediterránea';

  @override
  String get dietVegetarian => 'Vegetariana';
}

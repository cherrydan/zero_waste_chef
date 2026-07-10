// lib/utils/date_helpers.dart

import '../l10n/app_localizations.dart'; // Не забудь импорт вверху!

String getPopularProductName(String id, AppLocalizations l10n) {
  switch (id) {
    case 'tomatoes': return l10n.popTomatoes;
    case 'chicken': return l10n.popChicken;
    case 'feta': return l10n.popFeta;
    case 'eggs': return l10n.popEggs;
    case 'meat': return l10n.popMeat;
    case 'seafood': return l10n.popSeafood;
    case 'milk': return l10n.popMilk;
    default: return '';
  }
}


bool isProductExpired(DateTime? expiryDate) {
  if (expiryDate == null) return false;
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final expiry = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
  return expiry.isBefore(today);
}

bool isProductExpiringSoon(DateTime? expiryDate) {
  if (expiryDate == null) return false;
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final expiry = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
  final difference = expiry.difference(today).inDays;
  return difference >= 0 && difference <= 2;
}

String formatDate(DateTime? date) {
  if (date == null) return '';
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day.$month';
}

// lib/utils/date_helpers.dart

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

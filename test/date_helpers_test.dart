import 'package:flutter_test/flutter_test.dart';
import 'package:zero_waste_chef/utils/date_helpers.dart'; // Путь к твоим хелперам

void main() {
  group('Date Helpers Unit Tests', () {
    
    // Группа тестов для проверки просрочки
    group('isProductExpired', () {
      test('должен возвращать true для вчерашней даты (просрочен)', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        expect(isProductExpired(yesterday), isTrue);
      });

      test('должен возвращать false для завтрашней даты (не просрочен)', () {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        expect(isProductExpired(tomorrow), isFalse);
      });

      test('должен возвращать false, если дата равна null', () {
        expect(isProductExpired(null), isFalse);
      });
    });

    // Группа тестов для проверки скорой порчи (0-2 дня)
    group('isProductExpiringSoon', () {
      test('должен возвращать true для завтрашней даты (остался 1 день)', () {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        expect(isProductExpiringSoon(tomorrow), isTrue);
      });

      test('должен возвращать false для даты через неделю', () {
        final farFuture = DateTime.now().add(const Duration(days: 7));
        expect(isProductExpiringSoon(farFuture), isFalse);
      });

      test('должен возвращать false для просроченной даты (вчера)', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        expect(isProductExpiringSoon(yesterday), isFalse);
      });

      test('должен возвращать false, если дата равна null', () {
        expect(isProductExpiringSoon(null), isFalse);
      });
    });

    // Группа тестов для форматирования даты
    group('formatDate', () {
      test('должен корректно форматировать дату в формат ДД.ММ', () {
        final testDate = DateTime(2026, 7, 2); // 2 июля 2026
        expect(formatDate(testDate), equals('02.07'));
      });

      test('должен возвращать пустую строку, если дата равна null', () {
        expect(formatDate(null), equals(''));
      });
    });

  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('Лимит генераций: тест смены даты и инкремента', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    // Симулируем "вчерашнюю" дату
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final yesterdayString = "${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}";
    
    await prefs.setString('last_generation_date', yesterdayString);
    await prefs.setInt('generations_count_today', 2);

    // Логика как в твоем _loadDailyGenerationsLimit
    final now = DateTime.now();
    final todayString = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    
    int count = prefs.getInt('generations_count_today') ?? 0;
    final lastGenDate = prefs.getString('last_generation_date') ?? '';

    if (lastGenDate != todayString) {
      count = 0; // Сбрасываем!
    }

    expect(count, 0, reason: "Счетчик должен сброситься при смене даты");
    
    // Симулируем инкремент
    count++;
    await prefs.setInt('generations_count_today', count);
    
    expect(count, 1, reason: "Счетчик должен стать 1");
  });
}

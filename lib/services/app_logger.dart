import 'package:logger/logger.dart';

// Глобальный экземпляр логгера, который можно использовать везде
final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 1, // Показываем только 1 уровень стека вызова
    errorMethodCount: 5, // Для ошибок показываем 5 уровней
    lineLength: 80, // Длина строки лога
    colors: true, // Использовать цвета в консоли
    printEmojis: true, // Использовать эмодзи
    dateTimeFormat: DateTimeFormat.none, // <--- Использование нового параметра
  ),
);

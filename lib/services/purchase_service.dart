import 'dart:io';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../services/app_logger.dart'; // Наш логгер для отслеживания ошибок оплаты

class PurchaseService {
  // Системные ключи для связи с RevenueCat (получим их в админке позже)
  static const _googleApiKey = "goog_placeholder_key"; // Ключ для Android
  static const _appleApiKey = "appl_placeholder_key";   // Ключ для iOS

  // Инициализация сервиса покупок
  static Future<void> init() async {
    try {
      // Настраиваем режим отладки, чтобы видеть все логи платежей в консоли
      await Purchases.setLogLevel(LogLevel.debug);

      String apiKey = "";
      if (Platform.isAndroid) {
        apiKey = _googleApiKey;
      } else if (Platform.isIOS) {
        apiKey = _appleApiKey;
      }

      // Инициализируем конфигурацию RevenueCat
      PurchasesConfiguration configuration = PurchasesConfiguration(apiKey);
      await Purchases.configure(configuration);
      
      logger.i("RevenueCat успешно инициализирован!");
    } catch (e) {
      logger.e("Ошибка инициализации RevenueCat: $e");
    }
  }

  // Проверяем, активна ли у пользователя Premium подписка прямо сейчас
  static Future<bool> isUserPremium() async {
    try {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      // "premium" - это название нашего entitlement (права доступа), которое мы настроим в админке
      return customerInfo.entitlements.all["premium"]?.isActive ?? false;
    } catch (e) {
      logger.e("Ошибка проверки статуса подписки: $e");
      return false;
    }
  }
}

import 'dart:io';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../services/app_logger.dart'; // Наш логгер для отслеживания ошибок оплаты
import 'package:flutter/services.dart'; // Нужен для PlatformException
   


class PurchaseService {
  // Системные ключи для связи с RevenueCat (получим их в админке позже)
  static const _googleApiKey = "test_RTiIEKtNdoALeDKbjPdwZnmjxEd";
  static const _appleApiKey = "test_RTiIEKtNdoALeDKbjPdwZnmjxEd";
   


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

    // 🟢 1. Загружаем наше дефолтное предложение (Offering) из сети
  static Future<Offering?> getMonthlyOffering() async {
    try {
      Offerings offerings = await Purchases.getOfferings();
      // Ищем наше предложение с ID 'default'
      if (offerings.current != null) {
        return offerings.current;
      }
    } catch (e) {
      logger.e("Ошибка загрузки предложений: $e");
    }
    return null;
  }

      static Future<bool> purchasePackage(Package package) async {
    try {
      CustomerInfo customerInfo = await Purchases.purchasePackage(package);
      return customerInfo.entitlements.all["premium"]?.isActive ?? false;
    } on PlatformException catch (e) {
      // 🟢 Используем PurchasesErrorHelper для определения кода ошибки
      var errorCode = PurchasesErrorHelper.getErrorCode(e);
      
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        logger.i("Пользователь отменил покупку");
      } else {
        logger.e("Ошибка покупки: ${e.message}");
      }
      return false;
    } catch (e) {
      logger.e("Непредвиденная ошибка: $e");
      return false;
    }
  }



}

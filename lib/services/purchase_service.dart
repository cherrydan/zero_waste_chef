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

  // 🟢 Получаем дату окончания Premium подписки в красивом формате
  static Future<String?> getPremiumExpirationDate() async {
    try {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      final entitlement = customerInfo.entitlements.all["premium"];
      
      if (entitlement != null && entitlement.isActive) {
        // Используем dynamic, чтобы обойти строгость компилятора разных версий SDK
        final dynamic rawExpDate = entitlement.expirationDate;
        
        if (rawExpDate != null) {
          DateTime? expDateTime;
          
          if (rawExpDate is String) {
            expDateTime = DateTime.tryParse(rawExpDate);
          } else if (rawExpDate is DateTime) {
            expDateTime = rawExpDate;
          }
          
          if (expDateTime != null) {
            // Возвращаем дату в удобном формате: ДД.ММ.ГГГГ
            return "${expDateTime.day.toString().padLeft(2, '0')}.${expDateTime.month.toString().padLeft(2, '0')}.${expDateTime.year}";
          }
        }
      }
    } catch (e) {
      logger.e("Ошибка получения даты окончания подписки: $e");
    }
    return null;
  }



    // 🟢 Привязываем покупки к конкретному Firebase UID
  static Future<void> login(String firebaseUid) async {
    try {
      await Purchases.logIn(firebaseUid);
      logger.i("RevenueCat успешно привязан к Firebase UID: $firebaseUid");
    } catch (e) {
      logger.e("Ошибка привязки RevenueCat к UID: $e");
    }
  }

    // 🟢 Отвязываем покупки при выходе пользователя (с защитой от анонимного вызова)
  static Future<void> logout() async {
    try {
      // Проверяем, анонимный ли пользователь сейчас в RevenueCat
      bool isAnonymous = await Purchases.isAnonymous;
      
      if (!isAnonymous) {
        await Purchases.logOut();
        logger.i("RevenueCat успешно отвязан.");
      } else {
        logger.i("Пользователь уже анонимный, вызов logOut пропущен.");
      }
    } catch (e) {
      logger.e("Ошибка отвязки RevenueCat: $e");
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

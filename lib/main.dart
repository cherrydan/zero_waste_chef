import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Импорт Firebase
import 'package:zero_waste_chef/screens/auth_wrapper.dart';
import 'firebase_options.dart'; // Настройки Firebase
import 'l10n/app_localizations.dart'; // Наш новый авто-переводчик
import 'services/purchase_service.dart'; // Или твой правильный относительный путь
   

   


// Наш главный экран

void main() async {
  // 1. Убеждаемся, что движок Flutter готов к работе
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Инициализируем Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await PurchaseService.init(); //3. Инициализируем сервис покупок

  // 3. Запускаем приложение
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
        return MaterialApp(
      title: 'Zero Waste Chef',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      
      // ==========================================
      // ДОБАВЛЯЕМ СЮДА ЭТИ ДВЕ СТРОЧКИ:
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      // ==========================================

      home: const AuthWrapper(),
    );

  }
}

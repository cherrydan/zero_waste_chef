import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Импорт Firebase
import 'firebase_options.dart'; // Настройки Firebase
import 'screens/fridge_screen.dart'; // Наш главный экран

void main() async {
  // 1. Убеждаемся, что движок Flutter готов к работе
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Инициализируем Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 3. Запускаем приложение
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zero Waste Chef',
      debugShowCheckedModeBanner: false, // Убираем дебаг-баннер
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const FridgeScreen(), // Запускаем с экрана холодильника
    );
  }
}

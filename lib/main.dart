import 'package:flutter/material.dart';
import 'screens/fridge_screen.dart'; // Импортируем наш новый экран

void main() {
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
      home: const FridgeScreen(), // Запускаем приложение с экрана холодильника
    );
  }
}

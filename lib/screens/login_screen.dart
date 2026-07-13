import 'package:flutter/material.dart';
import 'package:zero_waste_chef/services/auth_service.dart';
import '../l10n/app_localizations.dart';
   


class LoginScreen extends StatelessWidget {
  final AuthService _auth = AuthService();

  LoginScreen({super.key});

   @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
   

    return Scaffold(
      body: Container(
        // Красивый мягкий эко-градиент на фоне
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green.shade50,
              Colors.white,
              Colors.green.shade100,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(height: 40),
                
                // Верхняя часть: Логотип и Приветствие
                Column(
                  children: [
                    // Наш сочный логотип-иконка
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withValues(alpha: 0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.spa_rounded, // Красивый листочек
                        size: 72,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Название приложения
                    Text(
                      l10n.appTitle,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 8),
                    
                    // Эко-слоган/Подзаголовок
                    Text(l10n.loginSlogan,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),

                // Наша кнопка входа (пока простая, по центру/снизу)
                                // 🟢 Стильная кнопка входа через Google
                SizedBox(
                  width: double.infinity, // Растягиваем на всю ширину
                  height: 54, // Делаем её повыше, чтобы было удобно нажимать
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white, // Чистый белый цвет кнопки
                      foregroundColor: Colors.black87, // Темный цвет текста
                      elevation: 3, // Мягкая тень
                      shadowColor: Colors.black.withValues(alpha: 0.1), // Цвет тени через withValues
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16), // Приятные закругленные углы
                      ),
                    ),
                    onPressed: () async {
                      await _auth.signInWithGoogle();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Иконка входа
                        const Icon(
                          Icons.login_rounded, 
                          color: Colors.green, // Эко-зеленый акцент
                        ),
                        const SizedBox(width: 12),
                        
                        // Локализованный текст
                        Text(
                          l10n.googleSignIn,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Небольшой отступ снизу для баланса
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

}

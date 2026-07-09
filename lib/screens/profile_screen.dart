import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../l10n/app_localizations.dart'; // <-- 1. Наш импорт локализации

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final AuthService authService = AuthService();
    
    // Создаем удобную переменную l10n, чтобы не писать длинный вызов каждый раз
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // 1. Аватарка пользователя
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.green.shade100,
                    backgroundImage: user?.photoURL != null
                        ? NetworkImage(user!.photoURL!)
                        : null,
                    child: user?.photoURL == null
                        ? const Icon(Icons.person, size: 60, color: Colors.green)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.verified, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 2. Имя пользователя
            Text(
              user?.displayName ?? 'Chef',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // 3. Email пользователя
            Text(
              user?.email ?? 'chef@zerowaste.com',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 32),

            const Divider(),
            const SizedBox(height: 16),

            // 4. Карточка статистики
            Row(
              children: [
                Expanded(
                  child: Card(
                    color: Colors.green.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Icon(Icons.eco, color: Colors.green),
                          const SizedBox(height: 8),
                          // ЗАМЕНИЛИ "Эко-статус":
                          Text(
                            l10n.ecoStatus, 
                            style: const TextStyle(fontWeight: FontWeight.bold)
                          ),
                          const Text('Zero Waste Pro', style: TextStyle(fontSize: 12, color: Colors.black54)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // 5. Кнопка Выхода
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.logout, color: Colors.red),
                // ЗАМЕНИЛИ "Выйти из аккаунта":
                label: Text(
                  l10n.logoutButton, 
                  style: const TextStyle(color: Colors.red)
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  await authService.signOut();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
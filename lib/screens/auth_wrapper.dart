import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'fridge_screen.dart';
import 'login_screen.dart';
import '../services/auth_service.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().user,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return const FridgeScreen(); // Пользователь вошел!
        } else {
          return LoginScreen(); // Пользователь не вошел
        }
      },
    );
  }
}

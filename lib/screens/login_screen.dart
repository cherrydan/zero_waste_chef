import 'package:flutter/material.dart';
import 'package:zero_waste_chef/services/auth_service.dart';

class LoginScreen extends StatelessWidget {
  final AuthService _auth = AuthService();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.login),
          label: const Text('Войти через Google'),
          onPressed: () async {
            await _auth.signInWithGoogle();
          },
        ),
      ),
    );
  }
}

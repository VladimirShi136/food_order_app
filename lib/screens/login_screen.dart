import 'package:flutter/material.dart';

import 'profile_screen.dart' show AuthForm;

/// Отдельный экран входа — открывается, например, из оформления заказа.
/// После успешного входа сам закрывается.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Вход')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: AuthForm(onSuccess: () => Navigator.of(context).pop()),
      ),
    );
  }
}

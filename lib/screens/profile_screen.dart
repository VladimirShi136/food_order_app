import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Профиль')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.surface,
                child: Icon(
                  Icons.person,
                  size: 40,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Вы не вошли в аккаунт',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: подключить Supabase Auth
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Вход появится после подключения Supabase',
                        ),
                      ),
                    );
                  },
                  child: const Text('Войти'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

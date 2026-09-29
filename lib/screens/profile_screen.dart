import 'package:flutter/material.dart';
import 'package:food_order_app/widgets/toast_stack.dart';

import '../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Профиль', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 24),
          Center(
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
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      toastController.show(
                        'Вход появится после подключения Supabase',
                      );
                    },
                    child: const Text('Войти'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
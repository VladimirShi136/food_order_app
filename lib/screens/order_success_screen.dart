import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'main_navigation_screen.dart';

class OrderSuccessScreen extends StatelessWidget {
  final String orderNumber;
  final String pickupTime;

  const OrderSuccessScreen({
    super.key,
    required this.orderNumber,
    required this.pickupTime,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: AppColors.background,
                  size: 56,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Заказ оформлен!',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Text(
                'Номер заказа: $orderNumber',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Заберите к: $pickupTime',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Адрес: г. Острогожск, ул. Карла Маркса 57',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => const MainNavigationScreen(),
                      ),
                      (route) => false,
                    );
                  },
                  child: const Text('На главную'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

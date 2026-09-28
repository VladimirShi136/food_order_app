import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Мои заказы')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.receipt_long,
                size: 64,
                color: AppColors.textSecondary,
              ),
              SizedBox(height: 16),
              Text(
                'У вас пока нет заказов',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

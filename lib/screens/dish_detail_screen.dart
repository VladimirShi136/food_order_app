import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../models/dish.dart';
import '../models/cart_model.dart';

class DishDetailScreen extends StatefulWidget {
  final Dish dish;

  const DishDetailScreen({super.key, required this.dish});

  @override
  State<DishDetailScreen> createState() => _DishDetailScreenState();
}

class _DishDetailScreenState extends State<DishDetailScreen> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    final dish = widget.dish;

    return Scaffold(
      appBar: AppBar(title: Text(dish.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 220,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.fastfood,
                size: 64,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            Text(dish.name, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              '${dish.price.toStringAsFixed(0)} ₽',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.remove_circle_outline,
                    color: AppColors.primary,
                  ),
                  onPressed: () {
                    if (quantity > 1) setState(() => quantity--);
                  },
                ),
                Text(
                  '$quantity',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                IconButton(
                  icon: const Icon(
                    Icons.add_circle_outline,
                    color: AppColors.primary,
                  ),
                  onPressed: () => setState(() => quantity++),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.read<CartModel>().addDish(dish, quantity: quantity);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${dish.name} добавлен в корзину')),
                  );
                },
                child: Text(
                  'Добавить в корзину · ${(dish.price * quantity).toStringAsFixed(0)} ₽',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

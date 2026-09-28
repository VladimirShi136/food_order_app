import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../models/cart_model.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Корзина')),
      body: cart.items.isEmpty
          ? const Center(
              child: Text(
                'Корзина пуста',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.dish.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${item.totalPrice.toStringAsFixed(0)} ₽',
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.remove_circle_outline,
                                color: AppColors.textSecondary,
                              ),
                              onPressed: () =>
                                  context.read<CartModel>().updateQuantity(
                                    item.dish.id,
                                    item.quantity - 1,
                                  ),
                            ),
                            Text('${item.quantity}'),
                            IconButton(
                              icon: const Icon(
                                Icons.add_circle_outline,
                                color: AppColors.primary,
                              ),
                              onPressed: () =>
                                  context.read<CartModel>().updateQuantity(
                                    item.dish.id,
                                    item.quantity + 1,
                                  ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: подключить оформление заказа на Этапе 4
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Оформление заказа появится позже'),
                          ),
                        );
                      },
                      child: Text(
                        'Оформить заказ · ${cart.totalPrice.toStringAsFixed(0)} ₽',
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

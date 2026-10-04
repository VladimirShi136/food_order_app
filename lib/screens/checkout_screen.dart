import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/auth_model.dart';
import '../models/cart_model.dart';
import '../services/order_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/toast_stack.dart';
import 'login_screen.dart';
import 'order_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final List<String> pickupOptions = [
    'Как можно скорее (~20 мин)',
    'Через 30 минут',
    'Через 1 час',
  ];
  String selectedTime = 'Как можно скорее (~20 мин)';
  final commentController = TextEditingController();
  final _repository = OrderRepository();
  bool _submitting = false;

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    final cart = context.read<CartModel>();
    final auth = context.read<AuthModel>();
    if (cart.items.isEmpty || _submitting) return;

    // Заказ может оформить только вошедший пользователь
    if (!auth.isLoggedIn) {
      await Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const LoginScreen()));
      if (!mounted || !auth.isLoggedIn) return;
    }

    setState(() => _submitting = true);
    try {
      final order = await _repository.create(
        items: List.of(cart.items),
        pickupTime: selectedTime,
        comment: commentController.text.trim(),
      );
      cart.clear();
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => OrderSuccessScreen(
            orderNumber: order.displayNumber,
            pickupTime: selectedTime,
          ),
        ),
      );
    } catch (e) {
      toastController.show(orderErrorMessage(e));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Оформление заказа')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Время самовывоза',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    ...pickupOptions.map(
                      (option) => RadioListTile<String>(
                        value: option,
                        groupValue: selectedTime,
                        onChanged: (value) =>
                            setState(() => selectedTime = value!),
                        title: Text(
                          option,
                          style: const TextStyle(color: AppColors.textPrimary),
                        ),
                        activeColor: AppColors.primary,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Оплата',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'При получении',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Комментарий к заказу',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: commentController,
                      maxLines: 3,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Например: без лука, позвонить перед выдачей',
                        hintStyle: const TextStyle(
                          color: AppColors.textSecondary,
                        ),
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Итого',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${cart.totalPrice.toStringAsFixed(0)} ₽',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitting ? null : _confirm,
                      child: _submitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.background,
                              ),
                            )
                          : const Text('Подтвердить заказ'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

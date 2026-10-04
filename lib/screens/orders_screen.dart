import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/auth_model.dart';
import '../models/order.dart';
import '../services/order_repository.dart';
import '../services/pocketbase_service.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthModel>();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Мои заказы', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Expanded(
            child: auth.isLoggedIn
                // key: при смене пользователя список создаётся заново
                ? _OrdersList(key: ValueKey(auth.userId))
                : const _LoginPrompt(),
          ),
        ],
      ),
    );
  }
}

class _LoginPrompt extends StatelessWidget {
  const _LoginPrompt();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.receipt_long,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          const Text(
            'Войдите, чтобы видеть свои заказы',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const LoginScreen())),
            child: const Text('Войти'),
          ),
        ],
      ),
    );
  }
}

class _OrdersList extends StatefulWidget {
  const _OrdersList({super.key});

  @override
  State<_OrdersList> createState() => _OrdersListState();
}

class _OrdersListState extends State<_OrdersList> {
  final _repository = OrderRepository();
  List<Order>? _orders;
  bool _failed = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _load();
    _subscribe();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    pb.collection('orders').unsubscribe('*');
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final orders = await _repository.myOrders();
      if (!mounted) return;
      setState(() {
        _orders = orders;
        _failed = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _failed = _orders == null);
    }
  }

  /// Realtime: когда ресторан меняет статус заказа, список обновляется сам.
  Future<void> _subscribe() async {
    try {
      await pb.collection('orders').subscribe('*', (event) {
        _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          if (mounted) _load();
        });
      });
    } catch (_) {
      // без realtime остаётся обновление свайпом вниз
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_orders == null && !_failed) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    if (_failed) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off,
              size: 48,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 12),
            const Text(
              'Не удалось загрузить заказы',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _load, child: const Text('Повторить')),
          ],
        ),
      );
    }

    final orders = _orders!;
    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      onRefresh: _load,
      child: orders.isEmpty
          ? ListView(
              children: const [
                SizedBox(height: 120),
                Center(
                  child: Text(
                    'У вас пока нет заказов',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            )
          : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(top: 8, bottom: 120),
              itemCount: orders.length,
              itemBuilder: (context, index) => _OrderCard(order: orders[index]),
            ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;

  const _OrderCard({required this.order});

  String _two(int n) => n.toString().padLeft(2, '0');

  String get _date {
    final d = order.created;
    return '${_two(d.day)}.${_two(d.month)}.${d.year} ${_two(d.hour)}:${_two(d.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Заказ №${order.displayNumber}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: order.statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  order.statusLabel,
                  style: TextStyle(
                    color: order.statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _date,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          for (final item in order.items)
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                '${item.quantity} × ${item.dishName}',
                style: const TextStyle(color: AppColors.textPrimary),
              ),
            ),
          if (order.pickupTime.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Самовывоз: ${order.pickupTime}',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${order.totalPrice.toStringAsFixed(0)} ₽',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

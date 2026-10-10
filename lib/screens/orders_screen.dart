import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/auth_model.dart';
import '../models/order.dart';
import '../services/order_repository.dart';
import '../services/pocketbase_service.dart';
import '../theme/app_theme.dart';
import '../widgets/auth_required_view.dart';
import '../widgets/cached_data_status.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/loading_state_view.dart';
import '../widgets/offline_state_view.dart';
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
          const SizedBox(height: 12),
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
    return AuthRequiredView(
      icon: Icons.receipt_long,
      title: 'Войдите, чтобы видеть свои заказы',
      message: 'После входа здесь появится история ваших заказов.',
      actionLabel: 'Войти',
      onAction: () =>
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const LoginScreen())),
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
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  List<Order>? _orders;
  bool _failed = false;
  bool _networkUnavailable = false;
  bool _isOffline = false;
  bool _loading = false;
  bool _refreshWhenIdle = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      _onConnectivityChanged,
      onError: (Object error) {
        debugPrint('Network connectivity monitoring failed: $error');
      },
    );
    _load();
    _subscribe();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _connectivitySubscription?.cancel();
    pb.collection('orders').unsubscribe('*');
    super.dispose();
  }

  void _onConnectivityChanged(List<ConnectivityResult> results) {
    final unavailable = results.contains(ConnectivityResult.none);
    if (!mounted) return;
    setState(() {
      _isOffline = unavailable;
      _networkUnavailable = unavailable && _orders != null;
    });
    if (!unavailable) _load();
  }

  Future<void> _load() async {
    if (_loading) {
      _refreshWhenIdle = true;
      return;
    }
    _loading = true;
    try {
      final orders = await _repository.myOrders();
      if (!mounted) return;
      setState(() {
        _orders = orders;
        _failed = false;
        _networkUnavailable = false;
      });
    } catch (error) {
      debugPrint('Orders refresh failed: $error');
      if (!mounted) return;
      final connectivity = await Connectivity().checkConnectivity();
      if (!mounted) return;
      setState(() {
        _failed = _orders == null;
        _isOffline = connectivity.contains(ConnectivityResult.none);
        _networkUnavailable = _orders != null;
      });
    } finally {
      _loading = false;
      if (_refreshWhenIdle && mounted) {
        _refreshWhenIdle = false;
        unawaited(_load());
      }
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
      return const LoadingStateView();
    }
    if (_failed) {
      return Padding(
        padding: const EdgeInsets.only(top: 16),
        child: OfflineStateView(
          title: 'Не удалось загрузить заказы',
          message: 'Проверьте подключение к интернету и попробуйте ещё раз.',
          onRetry: _load,
        ),
      );
    }

    final orders = _orders!;
    return Column(
      children: [
        if (_networkUnavailable)
          CachedDataStatus(
            isOffline: _isOffline,
            isStale: false,
            message: 'Не удалось обновить',
            onRefresh: _load,
            horizontalPadding: 0,
          ),
        Expanded(
          child: RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: AppColors.surface,
            onRefresh: _load,
            child: orders.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      const SizedBox(height: 80),
                      EmptyStateView(
                        icon: Icons.receipt_long,
                        title: 'У вас пока нет заказов',
                        message: 'Сделайте первый заказ — он появится здесь.',
                      ),
                    ],
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(top: 8, bottom: 120),
                    itemCount: orders.length,
                    itemBuilder: (context, index) =>
                        _OrderCard(order: orders[index]),
                  ),
          ),
        ),
      ],
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

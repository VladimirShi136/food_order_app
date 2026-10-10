import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

import '../models/admin_order.dart';

enum _OrderFilter {
  all,
  newOrders,
  accepted,
  cooking,
  ready,
  completed,
  cancelled,
}

class OrdersScreen extends StatefulWidget {
  final PocketBase client;
  final VoidCallback onSignOut;

  const OrdersScreen({
    super.key,
    required this.client,
    required this.onSignOut,
  });

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<AdminOrder> _orders = [];
  bool _loading = true;
  bool _loadingAgain = false;
  bool _refreshQueued = false;
  bool _realtimeAvailable = false;
  bool _busyUpdating = false;
  String? _error;
  String? _updatingOrderId;
  _OrderFilter _filter = _OrderFilter.all;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
    unawaited(_subscribe());
  }

  @override
  void dispose() {
    unawaited(widget.client.collection('orders').unsubscribe('*'));
    super.dispose();
  }

  Future<void> _subscribe() async {
    try {
      await widget.client.collection('orders').subscribe('*', (event) {
        unawaited(_load());
      });
      if (mounted) setState(() => _realtimeAvailable = true);
    } catch (error) {
      debugPrint('Order realtime subscription failed: $error');
      if (mounted) setState(() => _realtimeAvailable = false);
    }
  }

  Future<void> _load() async {
    if (_loadingAgain) {
      _refreshQueued = true;
      return;
    }
    _loadingAgain = true;
    if (mounted) {
      setState(() {
        _loading = _orders.isEmpty;
        _error = null;
      });
    }

    try {
      final records = await widget.client
          .collection('orders')
          .getFullList(sort: '-created', expand: 'order_items_via_order');
      if (!mounted) return;
      setState(() {
        _orders = records.map(AdminOrder.fromRecord).toList();
        _error = null;
      });
    } on ClientException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.statusCode == 0
            ? 'Нет связи с PocketBase. Проверьте подключение и сервер.'
            : 'Не удалось загрузить заказы. Проверьте права сотрудника.';
      });
    } catch (error) {
      debugPrint('Orders load failed: $error');
      if (mounted) setState(() => _error = 'Не удалось загрузить заказы.');
    } finally {
      _loadingAgain = false;
      if (mounted) setState(() => _loading = false);
      if (_refreshQueued && mounted) {
        _refreshQueued = false;
        unawaited(_load());
      }
    }
  }

  Future<void> _updateStatus(AdminOrder order, String status) async {
    if (_busyUpdating) return;
    setState(() {
      _busyUpdating = true;
      _updatingOrderId = order.id;
      _error = null;
    });
    try {
      await widget.client
          .collection('orders')
          .update(order.id, body: {'status': status});
      await _load();
    } on ClientException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.statusCode == 0
            ? 'Нет связи с PocketBase. Статус не обновлён.'
            : 'Не удалось изменить статус заказа.';
      });
    } catch (error) {
      debugPrint('Order status update failed: $error');
      if (mounted) {
        setState(() => _error = 'Не удалось изменить статус заказа.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _busyUpdating = false;
          _updatingOrderId = null;
        });
      }
    }
  }

  List<AdminOrder> get _visibleOrders => _orders.where((order) {
    return switch (_filter) {
      _OrderFilter.all => true,
      _OrderFilter.newOrders => order.status == 'new',
      _OrderFilter.accepted => order.status == 'accepted',
      _OrderFilter.cooking => order.status == 'cooking',
      _OrderFilter.ready => order.status == 'ready',
      _OrderFilter.completed => order.status == 'completed',
      _OrderFilter.cancelled => order.status == 'cancelled',
    };
  }).toList();

  @override
  Widget build(BuildContext context) {
    final orders = _visibleOrders;
    final staff = widget.client.authStore.record;
    final staffName = staff?.getStringValue('name').trim();
    final staffIdentity = staffName == null || staffName.isEmpty
        ? staff?.getStringValue('email') ?? ''
        : staffName;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gari Grill'),
        actions: [
          if (staffIdentity.isNotEmpty) ...[
            const Icon(Icons.person_outline, size: 20),
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 220),
              child: Text(staffIdentity, overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(width: 12),
          ],
          IconButton(
            tooltip: 'Обновить',
            onPressed: _loadingAgain ? null : _load,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Выйти',
            onPressed: widget.onSignOut,
            icon: const Icon(Icons.logout),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Заказы',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    Icon(
                      Icons.circle,
                      size: 10,
                      color: _realtimeAvailable
                          ? Colors.greenAccent
                          : Colors.orangeAccent,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _realtimeAvailable
                          ? 'Обновления онлайн'
                          : 'Обновите вручную',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 8,
                  children: [
                    _filterChip('Все', _OrderFilter.all),
                    _filterChip('Новые', _OrderFilter.newOrders),
                    _filterChip('Приняты', _OrderFilter.accepted),
                    _filterChip('Готовятся', _OrderFilter.cooking),
                    _filterChip('К выдаче', _OrderFilter.ready),
                    _filterChip('Выданы', _OrderFilter.completed),
                    _filterChip('Отменены', _OrderFilter.cancelled),
                  ],
                ),
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  _ErrorBanner(message: _error!, onRetry: _load),
                ],
                const SizedBox(height: 16),
                Expanded(
                  child: _loading
                      ? const Center(child: CircularProgressIndicator())
                      : orders.isEmpty
                      ? Center(
                          child: Text(
                            _orders.isEmpty
                                ? 'Пока заказов нет'
                                : 'В этой категории заказов нет',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _load,
                          child: ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: orders.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) => _OrderCard(
                              order: orders[index],
                              updating:
                                  _busyUpdating &&
                                  _updatingOrderId == orders[index].id,
                              onStatusSelected: (status) =>
                                  _updateStatus(orders[index], status),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _filterChip(String label, _OrderFilter filter) => FilterChip(
    label: Text(label),
    selected: _filter == filter,
    onSelected: (_) => setState(() => _filter = filter),
  );
}

class _OrderCard extends StatelessWidget {
  final AdminOrder order;
  final bool updating;
  final ValueChanged<String> onStatusSelected;

  const _OrderCard({
    required this.order,
    required this.updating,
    required this.onStatusSelected,
  });

  String _nextLabel(String status) => switch (status) {
    'new' => 'Принять',
    'accepted' => 'Начать готовить',
    'cooking' => 'Готов к выдаче',
    'ready' => 'Выдан',
    _ => '',
  };

  String? _nextStatus(String status) => switch (status) {
    'new' => 'accepted',
    'accepted' => 'cooking',
    'cooking' => 'ready',
    'ready' => 'completed',
    _ => null,
  };

  String _formattedDate(DateTime date) {
    String two(int value) => value.toString().padLeft(2, '0');
    return '${two(date.day)}.${two(date.month)}.${date.year} '
        '${two(date.hour)}:${two(date.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final nextStatus = _nextStatus(order.status);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  'Заказ №${order.displayNumber}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                _StatusLabel(text: order.statusLabel, status: order.status),
                Text(
                  _formattedDate(order.created),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            for (final item in order.items)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '${item.quantity} × ${item.name} '
                  '— ${(item.price * item.quantity).toStringAsFixed(0)} ₽',
                ),
              ),
            if (order.pickupTime.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Самовывоз: ${order.pickupTime}'),
            ],
            if (order.comment.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Комментарий: ${order.comment}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${order.total.toStringAsFixed(0)} ₽',
                    style: Theme.of(context).textTheme.titleLarge
                        ?.copyWith(color: const Color(0xFFF5B301)),
                  ),
                ),
                if (nextStatus != null)
                  FilledButton(
                    onPressed: updating
                        ? null
                        : () => onStatusSelected(nextStatus),
                    child: updating
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_nextLabel(order.status)),
                  ),
                if (order.status == 'new' || order.status == 'accepted') ...[
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: updating
                        ? null
                        : () => onStatusSelected('cancelled'),
                    child: const Text('Отменить'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusLabel extends StatelessWidget {
  final String text;
  final String status;

  const _StatusLabel({required this.text, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'ready' => Colors.greenAccent,
      'cancelled' => Colors.redAccent,
      'completed' => Colors.blueGrey,
      _ => const Color(0xFFF5B301),
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Text(
          text,
          style: TextStyle(color: color, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorBanner({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.redAccent.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      children: [
        Expanded(child: Text(message)),
        TextButton(onPressed: onRetry, child: const Text('Повторить')),
      ],
    ),
  );
}

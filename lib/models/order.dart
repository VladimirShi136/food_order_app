import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

import '../theme/app_theme.dart';

class OrderItem {
  final String dishName;
  final int quantity;
  final double price;

  const OrderItem({
    required this.dishName,
    required this.quantity,
    required this.price,
  });
}

class Order {
  final String id;
  final int number;
  final String status;
  final double totalPrice;
  final String pickupTime;
  final String comment;
  final DateTime created;
  final List<OrderItem> items;

  const Order({
    required this.id,
    required this.number,
    required this.status,
    required this.totalPrice,
    required this.pickupTime,
    required this.comment,
    required this.created,
    required this.items,
  });

  factory Order.fromRecord(RecordModel r) {
    final itemRecords = r.expand['order_items_via_order'] ?? <RecordModel>[];

    return Order(
      id: r.id,
      number: r.getIntValue('number'),
      status: r.getStringValue('status'),
      totalPrice: r.getDoubleValue('total_price'),
      pickupTime: r.getStringValue('pickup_time'),
      comment: r.getStringValue('comment'),
      created:
          DateTime.tryParse(r.getStringValue('created'))?.toLocal() ??
          DateTime.now(),
      items: itemRecords
          .map(
            (i) => OrderItem(
              dishName: i.getStringValue('dish_name'),
              quantity: i.getIntValue('quantity'),
              price: i.getDoubleValue('price_at_order'),
            ),
          )
          .toList(),
    );
  }

  /// Номер для показа клиенту.
  String get displayNumber => number > 0 ? '$number' : id.substring(0, 5);

  String get statusLabel => switch (status) {
    'new' => 'Новый',
    'accepted' => 'Принят',
    'cooking' => 'Готовится',
    'ready' => 'Готов к выдаче',
    'completed' => 'Выдан',
    'cancelled' => 'Отменён',
    _ => 'В обработке',
  };

  Color get statusColor => switch (status) {
    'ready' => const Color(0xFF4CAF50),
    'cancelled' => Colors.redAccent,
    'completed' => AppColors.textSecondary,
    _ => AppColors.primary,
  };
}

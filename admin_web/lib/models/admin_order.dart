import 'package:pocketbase/pocketbase.dart';

class AdminOrderItem {
  final String name;
  final int quantity;
  final double price;

  const AdminOrderItem({
    required this.name,
    required this.quantity,
    required this.price,
  });
}

class AdminOrder {
  final String id;
  final int number;
  final String status;
  final double total;
  final String pickupTime;
  final String comment;
  final DateTime created;
  final List<AdminOrderItem> items;

  const AdminOrder({
    required this.id,
    required this.number,
    required this.status,
    required this.total,
    required this.pickupTime,
    required this.comment,
    required this.created,
    required this.items,
  });

  factory AdminOrder.fromRecord(RecordModel record) {
    final expanded = record.get<List<RecordModel>>(
      'expand.order_items_via_order',
      const <RecordModel>[],
    );
    return AdminOrder(
      id: record.id,
      number: record.getIntValue('number'),
      status: record.getStringValue('status'),
      total: record.getDoubleValue('total_price'),
      pickupTime: record.getStringValue('pickup_time'),
      comment: record.getStringValue('comment'),
      created:
          DateTime.tryParse(record.getStringValue('created'))?.toLocal() ??
          DateTime.now(),
      items: expanded
          .map(
            (item) => AdminOrderItem(
              name: item.getStringValue('dish_name'),
              quantity: item.getIntValue('quantity'),
              price: item.getDoubleValue('price_at_order'),
            ),
          )
          .toList(),
    );
  }

  String get displayNumber => number > 0 ? '$number' : id.substring(0, 5);

  String get statusLabel => switch (status) {
    'new' => 'Новый',
    'accepted' => 'Принят',
    'cooking' => 'Готовится',
    'ready' => 'Готов к выдаче',
    'completed' => 'Выдан',
    'cancelled' => 'Отменён',
    _ => 'Неизвестен',
  };
}

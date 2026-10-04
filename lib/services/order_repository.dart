import 'package:pocketbase/pocketbase.dart';

import '../models/cart_model.dart';
import '../models/order.dart';
import 'pocketbase_service.dart';

class OrderRepository {
  /// Создаёт заказ и его позиции.
  /// Цены, номер и статус проставляет сервер (см. backend/pb_hooks/orders.pb.js),
  /// поэтому отправляем только то, что выбрал клиент.
  Future<Order> create({
    required List<CartItem> items,
    required String pickupTime,
    required String comment,
  }) async {
    final order = await pb
        .collection('orders')
        .create(
          body: {
            'user': pb.authStore.record!.id,
            'pickup_time': pickupTime,
            'comment': comment,
            'payment_method': 'cash',
          },
        );

    for (final item in items) {
      await pb
          .collection('order_items')
          .create(
            body: {
              'order': order.id,
              'dish': item.dish.id,
              'quantity': item.quantity,
            },
          );
    }

    final full = await pb
        .collection('orders')
        .getOne(order.id, expand: 'order_items_via_order');
    return Order.fromRecord(full);
  }

  /// Заказы текущего пользователя, новые сверху.
  Future<List<Order>> myOrders() async {
    final records = await pb
        .collection('orders')
        .getFullList(sort: '-created', expand: 'order_items_via_order');
    return records.map(Order.fromRecord).toList();
  }
}

/// Понятный текст ошибки оформления заказа.
String orderErrorMessage(Object error) {
  if (error is ClientException) {
    if (error.statusCode == 0) {
      return 'Нет связи с сервером. Заказ не отправлен.';
    }
    final message = error.response['message'];
    if (error.statusCode == 400 && message is String && message.isNotEmpty) {
      return message; // понятное сообщение от сервера, например «Блюдо недоступно»
    }
  }
  return 'Не удалось оформить заказ. Попробуйте ещё раз.';
}

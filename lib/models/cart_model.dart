import 'package:flutter/foundation.dart';

import 'dish.dart';

class CartItem {
  final Dish dish;
  int quantity;

  CartItem({required this.dish, this.quantity = 1});

  double get totalPrice => dish.price * quantity;
}

class CartModel extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  int get totalCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice => _items.fold(0, (sum, item) => sum + item.totalPrice);

  void addDish(Dish dish, {int quantity = 1}) {
    final existingIndex = _items.indexWhere((item) => item.dish.id == dish.id);
    if (existingIndex >= 0) {
      _items[existingIndex].quantity += quantity;
    } else {
      _items.add(CartItem(dish: dish, quantity: quantity));
    }
    notifyListeners();
  }

  void removeDish(String dishId) {
    _items.removeWhere((item) => item.dish.id == dishId);
    notifyListeners();
  }

  void updateQuantity(String dishId, int quantity) {
    final index = _items.indexWhere((item) => item.dish.id == dishId);
    if (index >= 0) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].quantity = quantity;
      }
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}

import 'package:flutter/material.dart';

import '../models/news_item.dart';
import 'catalog_screen.dart' show DishTile;

/// Список блюд, привязанных к акции (когда их несколько).
class PromoDishesScreen extends StatelessWidget {
  final NewsItem item;

  const PromoDishesScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(item.title)),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: item.dishes.length,
        itemBuilder: (context, index) => DishTile(dish: item.dishes[index]),
      ),
    );
  }
}

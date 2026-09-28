import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../models/dish.dart';

import 'package:provider/provider.dart';

import '../models/cart_model.dart';
import 'dish_detail_screen.dart';
import 'cart_screen.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  String selectedCategory = 'Все';

  @override
  Widget build(BuildContext context) {
    final filtered = selectedCategory == 'Все'
        ? sampleDishes
        : sampleDishes.where((d) => d.category == selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'GARI GRILL',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        actions: [
          Consumer<CartModel>(
            builder: (context, cart, _) => Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartScreen()),
                  ),
                ),
                if (cart.totalCount > 0)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${cart.totalCount}',
                        style: const TextStyle(
                          color: AppColors.background,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = cat == selectedCategory;
                return ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  onSelected: (_) => setState(() => selectedCategory = cat),
                  backgroundColor: AppColors.surface,
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? AppColors.background
                        : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final dish = filtered[index];
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DishDetailScreen(dish: dish),
                    ),
                  ),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dish.name,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${dish.price.toStringAsFixed(0)} ₽',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.add_circle,
                            color: AppColors.primary,
                          ),
                          onPressed: () {
                            context.read<CartModel>().addDish(dish);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${dish.name} добавлен в корзину',
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

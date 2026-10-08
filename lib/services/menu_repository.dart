import 'package:flutter/foundation.dart';

import '../models/dish.dart';
import 'cache_result.dart';
import 'pocketbase_service.dart';
import 'persistent_json_cache.dart';

class MenuData {
  final List<String> categories; // названия, уже по sort_order
  final List<Dish> dishes;

  const MenuData({required this.categories, required this.dishes});

  factory MenuData.fromJson(Map<String, dynamic> json) {
    return MenuData(
      categories: (json['categories'] as List<dynamic>).cast<String>(),
      dishes: (json['dishes'] as List<dynamic>)
          .map((dish) => Dish.fromJson(dish as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'categories': categories,
    'dishes': dishes.map((dish) => dish.toJson()).toList(),
  };
}

class MenuRepository {
  static const _cacheKey = 'cached_menu_v1';
  static const _freshness = Duration(hours: 24);
  final _cache = const PersistentJsonCache();

  /// Обновляет меню с сервера, используя сохранённую копию при ошибке связи.
  Future<CacheResult<MenuData>> load() async {
    late final MenuData menu;
    try {
      final categoryRecords = await pb
          .collection('categories')
          .getFullList(sort: 'sort_order');
      final dishRecords = await pb
          .collection('dishes')
          .getFullList(
            sort: 'name',
            filter: 'is_available = true',
            expand: 'category',
          );
      menu = MenuData(
        categories: categoryRecords
            .map((record) => record.getStringValue('name'))
            .toList(),
        dishes: dishRecords.map(Dish.fromRecord).toList(),
      );
    } catch (error, stackTrace) {
      final cached = await _cache.read(_cacheKey);
      if (cached == null) Error.throwWithStackTrace(error, stackTrace);
      debugPrint('Menu refresh failed; using cached menu: $error');
      final menu = MenuData.fromJson(cached.data as Map<String, dynamic>);
      final age = DateTime.now().difference(cached.savedAt);
      return CacheResult(
        value: menu,
        savedAt: cached.savedAt,
        isFromCache: true,
        isStale: age > _freshness,
      );
    }

    final savedAt = DateTime.now();
    final cached = await _cache.write(_cacheKey, menu.toJson());
    if (!cached) debugPrint('Unable to save the menu cache.');
    return CacheResult(
      value: menu,
      savedAt: savedAt,
      isFromCache: false,
      isStale: false,
    );
  }
}

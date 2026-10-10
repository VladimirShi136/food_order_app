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
  Future<CacheResult<MenuData>> load({
    void Function(CacheResult<MenuData> cached)? onCached,
  }) => _cache.load<MenuData>(
    key: _cacheKey,
    freshness: _freshness,
    fetch: () async {
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
      return MenuData(
        categories: categoryRecords
            .map((record) => record.getStringValue('name'))
            .toList(),
        dishes: dishRecords.map(Dish.fromRecord).toList(),
      );
    },
    encode: (menu) => menu.toJson(),
    decode: (data) => MenuData.fromJson(data as Map<String, dynamic>),
    onCached: onCached,
  );
}

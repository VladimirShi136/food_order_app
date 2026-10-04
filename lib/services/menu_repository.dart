import '../models/dish.dart';
import 'pocketbase_service.dart';

class MenuData {
  final List<String> categories; // названия, уже по sort_order
  final List<Dish> dishes;

  const MenuData({required this.categories, required this.dishes});
}

class MenuRepository {
  /// Загружает категории и доступные блюда с сервера.
  Future<MenuData> load() async {
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
      categories: categoryRecords.map((r) => r.getStringValue('name')).toList(),
      dishes: dishRecords.map(Dish.fromRecord).toList(),
    );
  }
}

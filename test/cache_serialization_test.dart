import 'package:flutter_test/flutter_test.dart';
import 'package:food_order_app/models/dish.dart';
import 'package:food_order_app/models/news_item.dart';
import 'package:food_order_app/services/persistent_json_cache.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('persistent cache stores a timestamp and JSON data', () async {
    SharedPreferences.setMockInitialValues({});
    const cache = PersistentJsonCache();

    expect(await cache.write('test_cache', {'value': 42}), isTrue);
    final restored = await cache.read('test_cache');

    expect(restored, isNotNull);
    expect(restored!.data, {'value': 42});
    expect(restored.savedAt.isBefore(DateTime.now()), isTrue);
  });

  test('dish survives JSON cache serialization', () {
    const dish = Dish(
      id: 'dish-id',
      name: 'Бургер',
      description: 'С сыром',
      category: 'Бургеры',
      price: 350,
      imageUrl: 'http://localhost:8090/image.jpg',
    );

    final restored = Dish.fromJson(dish.toJson());

    expect(restored.id, dish.id);
    expect(restored.name, dish.name);
    expect(restored.description, dish.description);
    expect(restored.category, dish.category);
    expect(restored.price, dish.price);
    expect(restored.imageUrl, dish.imageUrl);
  });

  test('news and linked dishes survive JSON cache serialization', () {
    final expiresAt = DateTime(2026, 10, 10, 12);
    final news = NewsItem(
      id: 'news-id',
      title: 'Акция',
      body: 'Скидка на бургер',
      kind: 'promo',
      imageUrl: 'http://localhost:8090/promo.jpg',
      pinned: true,
      expiresAt: expiresAt,
      dishes: const [
        Dish(id: 'dish-id', name: 'Бургер', category: 'Бургеры', price: 350),
      ],
    );

    final restored = NewsItem.fromJson(news.toJson());

    expect(restored.id, news.id);
    expect(restored.title, news.title);
    expect(restored.body, news.body);
    expect(restored.kind, news.kind);
    expect(restored.imageUrl, news.imageUrl);
    expect(restored.pinned, isTrue);
    expect(restored.expiresAt, expiresAt);
    expect(restored.dishes.single.name, 'Бургер');
  });
}

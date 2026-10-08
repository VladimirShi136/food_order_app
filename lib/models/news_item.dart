import 'package:pocketbase/pocketbase.dart';

import '../config.dart';
import 'dish.dart';

class NewsItem {
  final String id;
  final String title;
  final String body;
  final String kind; // 'promo' или 'news'
  final String imageUrl; // пустая строка, если фото нет
  final bool pinned;
  final DateTime? expiresAt;
  final List<Dish> dishes; // связанные блюда (только доступные)

  const NewsItem({
    required this.id,
    required this.title,
    required this.body,
    required this.kind,
    required this.imageUrl,
    required this.pinned,
    required this.expiresAt,
    required this.dishes,
  });

  bool get isPromo => kind == 'promo';

  factory NewsItem.fromRecord(RecordModel r) {
    final file = r.getStringValue('image');
    final dishRecords = r.expand['dishes'] ?? <RecordModel>[];

    return NewsItem(
      id: r.id,
      title: r.getStringValue('title'),
      body: r.getStringValue('body'),
      kind: r.getStringValue('kind'),
      imageUrl: file.isEmpty
          ? ''
          : '${AppConfig.pocketBaseUrl}/api/files/${r.collectionId}/${r.id}/$file',
      pinned: r.getBoolValue('pinned'),
      expiresAt: DateTime.tryParse(r.getStringValue('expires_at'))?.toLocal(),
      dishes: dishRecords
          .where((d) => d.getBoolValue('is_available'))
          .map(Dish.fromRecord)
          .toList(),
    );
  }

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    final rawDishes = json['dishes'] as List<dynamic>? ?? const [];
    return NewsItem(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String? ?? '',
      kind: json['kind'] as String,
      imageUrl: json['imageUrl'] as String? ?? '',
      pinned: json['pinned'] as bool? ?? false,
      expiresAt: DateTime.tryParse(json['expiresAt'] as String? ?? ''),
      dishes: rawDishes
          .map((dish) => Dish.fromJson(dish as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'kind': kind,
    'imageUrl': imageUrl,
    'pinned': pinned,
    'expiresAt': expiresAt?.toIso8601String(),
    'dishes': dishes.map((dish) => dish.toJson()).toList(),
  };
}

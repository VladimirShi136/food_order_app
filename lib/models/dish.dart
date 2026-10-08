import 'package:pocketbase/pocketbase.dart';

import '../config.dart';

class Dish {
  final String id;
  final String name;
  final String description;
  final String category; // название категории
  final double price;
  final String imageUrl; // пустая строка, если фото нет

  const Dish({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    this.description = '',
    this.imageUrl = '',
  });

  factory Dish.fromRecord(RecordModel r) {
    final categories = r.expand['category'];
    final categoryName = (categories != null && categories.isNotEmpty)
        ? categories.first.getStringValue('name')
        : '';

    final fileName = r.getStringValue('image');
    final imageUrl = fileName.isEmpty
        ? ''
        : '${AppConfig.pocketBaseUrl}/api/files/${r.collectionId}/${r.id}/$fileName';

    return Dish(
      id: r.id,
      name: r.getStringValue('name'),
      description: r.getStringValue('description'),
      category: categoryName,
      price: r.getDoubleValue('price'),
      imageUrl: imageUrl,
    );
  }

  factory Dish.fromJson(Map<String, dynamic> json) {
    return Dish(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'category': category,
    'price': price,
    'imageUrl': imageUrl,
  };
}

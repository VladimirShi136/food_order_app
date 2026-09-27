class Dish {
  final String id;
  final String name;
  final String category;
  final double price;
  final String imageUrl;

  const Dish({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.imageUrl,
  });
}

final List<String> categories = [
  'Все',
  'Шаурма',
  'Бургеры',
  'Картофель',
  'Комбо',
];

final List<Dish> sampleDishes = [
  Dish(
    id: '1',
    name: 'Шаурма с курицей',
    category: 'Шаурма',
    price: 220,
    imageUrl: '',
  ),
  Dish(
    id: '2',
    name: 'Шаурма острая',
    category: 'Шаурма',
    price: 240,
    imageUrl: '',
  ),
  Dish(
    id: '3',
    name: 'Классический бургер',
    category: 'Бургеры',
    price: 280,
    imageUrl: '',
  ),
  Dish(
    id: '4',
    name: 'Картофель фри',
    category: 'Картофель',
    price: 150,
    imageUrl: '',
  ),
  Dish(id: '5', name: 'Комбо №1', category: 'Комбо', price: 450, imageUrl: ''),
];

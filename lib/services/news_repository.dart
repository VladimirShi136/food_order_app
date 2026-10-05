import '../models/news_item.dart';
import 'pocketbase_service.dart';

class NewsRepository {
  /// Опубликованные новости и акции: сначала закреплённые, затем новые.
  /// Скрытые и истёкшие сервер отфильтровывает сам (правила коллекции).
  Future<List<NewsItem>> load() async {
    final records = await pb
        .collection('news')
        .getFullList(sort: '-pinned,-created', expand: 'dishes.category');
    return records.map(NewsItem.fromRecord).toList();
  }
}

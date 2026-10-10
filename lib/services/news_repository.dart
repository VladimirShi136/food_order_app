import '../models/news_item.dart';
import 'cache_result.dart';
import 'pocketbase_service.dart';
import 'persistent_json_cache.dart';

class NewsRepository {
  static const _cacheKey = 'cached_news_v1';
  static const _freshness = Duration(hours: 3);
  final _cache = const PersistentJsonCache();

  /// Опубликованные новости и акции: сначала закреплённые, затем новые.
  /// Скрытые и истёкшие сервер отфильтровывает сам (правила коллекции).
  Future<CacheResult<List<NewsItem>>> load({
    void Function(CacheResult<List<NewsItem>> cached)? onCached,
  }) =>
      _cache.load<List<NewsItem>>(
        key: _cacheKey,
        freshness: _freshness,
        fetch: () async {
          final records = await pb
              .collection('news')
              .getFullList(sort: '-pinned,-created', expand: 'dishes.category');
          return records.map(NewsItem.fromRecord).toList();
        },
        encode: (items) => items.map((item) => item.toJson()).toList(),
        decode: (data) => (data as List<dynamic>)
            .map((item) => NewsItem.fromJson(item as Map<String, dynamic>))
            .where(
              (item) =>
                  item.expiresAt == null ||
                  item.expiresAt!.isAfter(DateTime.now()),
            )
            .toList(),
        onCached: onCached,
      );
}

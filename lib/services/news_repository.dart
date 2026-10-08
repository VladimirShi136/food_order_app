import 'package:flutter/foundation.dart';

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
  Future<CacheResult<List<NewsItem>>> load() async {
    late final List<NewsItem> items;
    try {
      final records = await pb
          .collection('news')
          .getFullList(sort: '-pinned,-created', expand: 'dishes.category');
      items = records.map(NewsItem.fromRecord).toList();
    } catch (error, stackTrace) {
      final cached = await _cache.read(_cacheKey);
      if (cached == null) Error.throwWithStackTrace(error, stackTrace);
      debugPrint('News refresh failed; using cached news: $error');
      final items = (cached.data as List<dynamic>)
          .map((item) => NewsItem.fromJson(item as Map<String, dynamic>))
          .where(
            (item) => item.expiresAt == null || item.expiresAt!.isAfter(DateTime.now()),
          )
          .toList();
      final age = DateTime.now().difference(cached.savedAt);
      return CacheResult(
        value: items,
        savedAt: cached.savedAt,
        isFromCache: true,
        isStale: age > _freshness,
      );
    }

    final savedAt = DateTime.now();
    final cached = await _cache.write(
      _cacheKey,
      items.map((item) => item.toJson()).toList(),
    );
    if (!cached) debugPrint('Unable to save the news cache.');
    return CacheResult(
      value: items,
      savedAt: savedAt,
      isFromCache: false,
      isStale: false,
    );
  }
}

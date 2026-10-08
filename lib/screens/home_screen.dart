import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import '../models/news_item.dart';
import '../services/news_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/cached_data_banner.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/loading_state_view.dart';
import '../widgets/offline_state_view.dart';
import '../widgets/zoomable_image.dart';
import 'dish_detail_screen.dart';
import 'promo_dishes_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with WidgetsBindingObserver {
  final _repository = NewsRepository();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  List<NewsItem>? _items;
  DateTime? _cacheSavedAt;
  DateTime? _lastUpdatedAt;
  bool _cacheIsStale = false;
  bool _networkUnavailable = false;
  bool _failed = false;
  bool _loading = false;
  bool _refreshWhenIdle = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      _onConnectivityChanged,
      onError: (Object error) {
        debugPrint('Network connectivity monitoring failed: $error');
      },
    );
    _load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _networkUnavailable) _load();
  }

  void _onConnectivityChanged(List<ConnectivityResult> results) {
    final unavailable = results.contains(ConnectivityResult.none);
    if (!mounted) return;
    if (unavailable) {
      if (_networkUnavailable) return;
      setState(() {
        _networkUnavailable = true;
        _failed = _items == null;
        _cacheSavedAt ??= _lastUpdatedAt;
        _cacheIsStale =
            _lastUpdatedAt != null &&
            DateTime.now().difference(_lastUpdatedAt!) >
                const Duration(hours: 3);
      });
      return;
    }

    if (_networkUnavailable) {
      setState(() => _networkUnavailable = false);
    }
    _load();
  }

  Future<void> _load() async {
    if (_loading) {
      _refreshWhenIdle = true;
      return;
    }
    _loading = true;
    try {
      final result = await _repository.load();
      if (!mounted) return;
      setState(() {
        _items = result.value;
        _cacheSavedAt = result.isFromCache ? result.savedAt : null;
        _lastUpdatedAt = result.savedAt;
        _cacheIsStale = result.isStale;
        _networkUnavailable = result.isFromCache;
        _failed = false;
      });
    } catch (error) {
      if (!mounted) return;
      debugPrint('News refresh failed and no cached result was returned: $error');
      // если данные уже были, оставляем их на экране
      setState(() {
        _failed = _items == null;
        _networkUnavailable = true;
        _cacheSavedAt ??= _lastUpdatedAt;
        _cacheIsStale =
            _lastUpdatedAt != null &&
            DateTime.now().difference(_lastUpdatedAt!) >
                const Duration(hours: 3);
      });
    } finally {
      _loading = false;
      if (_refreshWhenIdle && mounted) {
        _refreshWhenIdle = false;
        unawaited(_load());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Text(
            'Новости и акции',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        Expanded(
          child: _items == null
              ? _failed
                    ? OfflineStateView(
                        title: 'Не удалось загрузить новости',
                        message: 'Проверьте подключение к интернету и попробуйте ещё раз.',
                        onRetry: _load,
                      )
                    : const LoadingStateView()
              : RefreshIndicator(
                  color: AppColors.primary,
                  backgroundColor: AppColors.surface,
                  onRefresh: _load,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
                    children: [
                      if (_items!.isEmpty) ...[
                        if (_networkUnavailable && _cacheSavedAt != null)
                          CachedDataBanner(
                            savedAt: _cacheSavedAt!,
                            isStale: _cacheIsStale,
                            onRefresh: _load,
                          ),
                        Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: EmptyStateView(
                            icon: Icons.campaign_outlined,
                            title: 'Пока новостей нет',
                            message:
                                'Скоро появятся свежие акции и обновления.',
                          ),
                        ),
                      ] else ...[
                        if (_networkUnavailable && _cacheSavedAt != null)
                          CachedDataBanner(
                            savedAt: _cacheSavedAt!,
                            isStale: _cacheIsStale,
                            onRefresh: _load,
                          ),
                        for (final item in _items!) _NewsCard(item: item),
                      ],
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}

class _NewsCard extends StatelessWidget {
  final NewsItem item;

  const _NewsCard({required this.item});

  String _two(int n) => n.toString().padLeft(2, '0');

  void _openDishes(BuildContext context) {
    final Widget screen = item.dishes.length == 1
        ? DishDetailScreen(dish: item.dishes.first)
        : PromoDishesScreen(item: item);
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final until = item.expiresAt;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        // закреплённая карточка выделена золотой рамкой
        border: item.pinned
            ? Border.all(color: AppColors.primary.withValues(alpha: 0.7))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.imageUrl.isNotEmpty) ...[
            ZoomableImage(url: item.imageUrl),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              Icon(
                item.isPromo ? Icons.local_fire_department : Icons.campaign,
                color: AppColors.primary,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                item.isPromo ? 'АКЦИЯ' : 'НОВОСТЬ',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              if (item.pinned) ...[
                const SizedBox(width: 8),
                const Icon(Icons.push_pin, color: AppColors.primary, size: 14),
              ],
              if (until != null) ...[
                const Spacer(),
                Text(
                  'до ${_two(until.day)}.${_two(until.month)}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(item.title, style: Theme.of(context).textTheme.titleMedium),
          if (item.body.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              item.body,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
          if (item.dishes.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => _openDishes(context),
                child: Text(
                  item.dishes.length == 1
                      ? 'Посмотреть блюдо'
                      : 'Посмотреть блюда (${item.dishes.length})',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

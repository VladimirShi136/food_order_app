import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:food_order_app/widgets/toast_stack.dart';
import 'package:provider/provider.dart';

import '../models/cart_model.dart';
import '../models/dish.dart';
import '../services/cache_result.dart';
import '../services/menu_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/cached_data_banner.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/loading_state_view.dart';
import '../widgets/offline_state_view.dart';
import 'dish_detail_screen.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen>
    with WidgetsBindingObserver {
  static const _all = 'Все';

  final _repository = MenuRepository();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  late Future<CacheResult<MenuData>> _menuFuture;
  String selectedCategory = _all;
  bool _networkUnavailable = false;
  bool _loading = false;
  bool _refreshWhenIdle = false;
  DateTime? _lastUpdatedAt;

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
    _loading = true;
    _menuFuture = _repository.load();
    _menuFuture.then(
      (result) {
        if (!mounted) return;
        _lastUpdatedAt = result.savedAt;
        _networkUnavailable = result.isFromCache;
        _finishLoading();
      },
      onError: (Object error) {
        debugPrint('Initial menu load failed: $error');
        _finishLoading();
      },
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _reload();
  }

  void _onConnectivityChanged(List<ConnectivityResult> results) {
    final unavailable = results.contains(ConnectivityResult.none);
    if (!mounted) return;
    if (unavailable) {
      if (_networkUnavailable) return;
      setState(() => _networkUnavailable = true);
      return;
    }

    if (_networkUnavailable) {
      setState(() => _networkUnavailable = false);
    }
    _reload();
  }

  Future<void> _reload() async {
    if (_loading) {
      _refreshWhenIdle = true;
      return;
    }
    _loading = true;
    final future = _repository.load();
    setState(() {
      _menuFuture = future;
    });
    try {
      final result = await future;
      if (!mounted) return;
      setState(() {
        _lastUpdatedAt = result.savedAt;
        _networkUnavailable = result.isFromCache;
      });
    } catch (error) {
      debugPrint('Menu refresh failed: $error');
      if (!mounted) return;
      setState(() => _networkUnavailable = true);
    } finally {
      _finishLoading();
    }
  }

  void _finishLoading() {
    _loading = false;
    if (_refreshWhenIdle && mounted) {
      _refreshWhenIdle = false;
      unawaited(_reload());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Text('Меню', style: Theme.of(context).textTheme.titleMedium),
        ),
        Expanded(
          child: FutureBuilder<CacheResult<MenuData>>(
            future: _menuFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const LoadingStateView();
              }
              if (snapshot.hasError || !snapshot.hasData) {
                return OfflineStateView(
                  title: 'Не удалось загрузить меню',
                  message:
                      'Проверьте подключение к интернету и попробуйте ещё раз.',
                  onRetry: _reload,
                );
              }
              final result = snapshot.data!;
              return _buildMenu(
                context,
                result,
                isOffline: _networkUnavailable || result.isFromCache,
                savedAt: result.isFromCache
                    ? result.savedAt
                    : (_lastUpdatedAt ?? result.savedAt),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMenu(
    BuildContext context,
    CacheResult<MenuData> result, {
    required bool isOffline,
    required DateTime savedAt,
  }) {
    final menu = result.value;
    final categories = [_all, ...menu.categories];
    final filtered = selectedCategory == _all
        ? menu.dishes
        : menu.dishes.where((d) => d.category == selectedCategory).toList();

    return Column(
      children: [
        if (isOffline)
          CachedDataBanner(
            savedAt: savedAt,
            isStale:
                result.isStale ||
                DateTime.now().difference(savedAt) > const Duration(hours: 24),
            onRefresh: _reload,
          ),
        const SizedBox(height: 4),
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final cat = categories[index];
              final isSelected = cat == selectedCategory;
              return ChoiceChip(
                label: Text(cat),
                selected: isSelected,
                onSelected: (_) => setState(() => selectedCategory = cat),
                backgroundColor: AppColors.surface,
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: isSelected
                      ? AppColors.background
                      : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: AppColors.surface,
            onRefresh: _reload,
            child: filtered.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      const SizedBox(height: 80),
                      EmptyStateView(
                        icon: Icons.category_outlined,
                        title: 'В этой категории пока пусто',
                        message: 'Попробуйте выбрать другую категорию.',
                      ),
                    ],
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) =>
                        DishTile(dish: filtered[index]),
                  ),
          ),
        ),
      ],
    );
  }
}

class DishTile extends StatelessWidget {
  final Dish dish;

  const DishTile({super.key, required this.dish});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DishDetailScreen(dish: dish)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            DishImage(url: dish.imageUrl, size: 64, radius: 12),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dish.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${dish.price.toStringAsFixed(0)} ₽',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle, color: AppColors.primary),
              onPressed: () {
                context.read<CartModel>().addDish(dish);
                toastController.show('${dish.name} добавлен в корзину');
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Фото блюда с заглушкой, пока грузится или если фото нет.
class DishImage extends StatelessWidget {
  final String url;
  final double? size;
  final double height;
  final double radius;

  const DishImage({
    super.key,
    required this.url,
    this.size,
    this.height = 0,
    this.radius = 12,
  });

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      color: AppColors.background,
      alignment: Alignment.center,
      child: const Icon(Icons.fastfood, color: AppColors.textSecondary),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        width: size ?? double.infinity,
        height: size ?? height,
        child: url.isEmpty
            ? placeholder
            : CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                placeholder: (_, __) => placeholder,
                errorWidget: (_, __, ___) => placeholder,
              ),
      ),
    );
  }
}

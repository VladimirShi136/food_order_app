import 'package:flutter/material.dart';

import '../models/news_item.dart';
import '../services/news_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/zoomable_image.dart';
import 'dish_detail_screen.dart';
import 'promo_dishes_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _repository = NewsRepository();
  List<NewsItem>? _items;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final items = await _repository.load();
      if (!mounted) return;
      setState(() {
        _items = items;
        _failed = false;
      });
    } catch (_) {
      if (!mounted) return;
      // если данные уже были, оставляем их на экране
      setState(() => _failed = _items == null);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_items == null && !_failed) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    if (_failed) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off,
              size: 48,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 12),
            const Text(
              'Не удалось загрузить новости',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _load, child: const Text('Повторить')),
          ],
        ),
      );
    }

    final items = _items!;
    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        children: [
          Text(
            'Новости и акции',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 80),
              child: Center(
                child: Text(
                  'Пока новостей нет',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            )
          else
            for (final item in items) _NewsCard(item: item),
        ],
      ),
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

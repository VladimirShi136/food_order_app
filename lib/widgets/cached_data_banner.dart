import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class CachedDataBanner extends StatelessWidget {
  final DateTime savedAt;
  final bool isStale;
  final VoidCallback? onRefresh;

  const CachedDataBanner({
    super.key,
    required this.savedAt,
    required this.isStale,
    this.onRefresh,
  });

  String _twoDigits(int value) => value.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final timestamp =
        '${_twoDigits(savedAt.day)}.${_twoDigits(savedAt.month)} '
        '${_twoDigits(savedAt.hour)}:${_twoDigits(savedAt.minute)}';
    final message = isStale
        ? 'Нет связи с сервером. Кеш может быть устаревшим (сохранён $timestamp).'
        : 'Нет связи с сервером. Показаны сохранённые данные от $timestamp.';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          if (onRefresh != null) ...[
            const SizedBox(height: 4),
            TextButton(onPressed: onRefresh, child: const Text('Обновить')),
          ],
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class OfflineStateView extends StatelessWidget {
  final String title;
  final String message;
  final Future<void> Function()? onRetry;
  final String retryLabel;

  const OfflineStateView({
    super.key,
    this.title = 'Нет доступа к сети',
    this.message = 'Проверьте подключение к интернету и попробуйте ещё раз.',
    this.onRetry,
    this.retryLabel = 'Повторить',
  });

  @override
  Widget build(BuildContext context) {
    final content = Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off,
              size: 48,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRetry,
                child: Text(retryLabel),
              ),
            ],
          ],
        ),
      ),
    );

    if (onRetry == null) return content;

    return LayoutBuilder(
      builder: (context, constraints) => RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        onRefresh: onRetry!,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: content,
          ),
        ),
      ),
    );
  }
}

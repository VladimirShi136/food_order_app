import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

import '../theme/app_theme.dart';

/// Картинка на всю ширину карточки с сохранением пропорций (без обрезки).
/// Слишком высокие картинки ограничиваются по высоте, но показываются целиком.
/// По нажатию открывается полноэкранный просмотр с увеличением.
class ZoomableImage extends StatelessWidget {
  final String url;
  final double maxHeight;
  final double radius;

  const ZoomableImage({
    super.key,
    required this.url,
    this.maxHeight = 420,
    this.radius = 12,
  });

  void _openViewer(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        fullscreenDialog: true,
        transitionDuration: const Duration(milliseconds: 220),
        reverseTransitionDuration: const Duration(milliseconds: 180),
        pageBuilder: (_, __, ___) => ImageViewerScreen(url: url),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      height: 120,
      color: AppColors.background,
      alignment: Alignment.center,
      child: const Icon(Icons.image, color: AppColors.textSecondary),
    );

    return GestureDetector(
      onTap: () => _openViewer(context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Stack(
          children: [
            // Высота плавно подстраивается, когда картинка догрузилась
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: maxHeight),
                child: ColoredBox(
                  color: AppColors.background,
                  child: CachedNetworkImage(
                    imageUrl: url,
                    // без перекрёстного затухания: иначе на миг видны
                    // тёмные полосы от заглушки
                    fadeInDuration: Duration.zero,
                    fadeOutDuration: Duration.zero,
                    placeholder: (_, __) => placeholder,
                    errorWidget: (_, __, ___) => placeholder,
                    // Полная ширина, высота по пропорциям картинки
                    imageBuilder: (_, provider) => Image(
                      image: provider,
                      width: double.infinity,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 8,
              bottom: 8,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.zoom_out_map,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Полноэкранный просмотр: щипок — масштаб, перетаскивание — сдвиг,
/// двойное нажатие — увеличить/вернуть. Построен на пакете photo_view.
class ImageViewerScreen extends StatelessWidget {
  final String url;

  const ImageViewerScreen({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: PhotoView(
              imageProvider: CachedNetworkImageProvider(url),
              backgroundDecoration: const BoxDecoration(color: Colors.black),
              // при открытии картинка целиком вписана в экран
              initialScale: PhotoViewComputedScale.contained,
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.contained * 6,
              loadingBuilder: (_, __) => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              errorBuilder: (_, __, ___) => const Center(
                child: Icon(
                  Icons.broken_image,
                  color: AppColors.textSecondary,
                  size: 48,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: IconButton(
                style: IconButton.styleFrom(backgroundColor: Colors.black54),
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

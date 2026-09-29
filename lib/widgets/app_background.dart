import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class _FoodPatternPainter extends CustomPainter {
  static const List<IconData> _icons = [
    Icons.local_fire_department,
    Icons.fastfood,
    Icons.lunch_dining,
    Icons.local_pizza,
    Icons.ramen_dining,
    Icons.icecream,
    Icons.bakery_dining,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    const spacing = 76.0;
    const iconSize = 26.0;
    final color = AppColors.primary.withOpacity(0.08);

    int index = 0;
    int rowIndex = 0;
    for (double y = -spacing; y < size.height + spacing; y += spacing) {
      final rowOffset = (rowIndex % 2 == 0) ? 0.0 : spacing / 2;
      for (double x = -spacing; x < size.width + spacing; x += spacing) {
        final icon = _icons[index % _icons.length];
        final painter = TextPainter(textDirection: TextDirection.ltr)
          ..text = TextSpan(
            text: String.fromCharCode(icon.codePoint),
            style: TextStyle(
              fontFamily: icon.fontFamily,
              package: icon.fontPackage,
              fontSize: iconSize,
              color: color,
            ),
          )
          ..layout();

        canvas.save();
        canvas.translate(x + rowOffset, y);
        canvas.rotate(((index % 5) - 2) * 0.12);
        painter.paint(canvas, Offset.zero);
        canvas.restore();
        index++;
      }
      rowIndex++;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AppBackground extends StatelessWidget {
  const AppBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: RepaintBoundary(
        child: CustomPaint(painter: _FoodPatternPainter(), size: Size.infinite),
      ),
    );
  }
}

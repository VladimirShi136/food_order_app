import 'package:flutter/material.dart';
import 'package:food_order_app/screens/splash_screen.dart';
import 'package:provider/provider.dart';

import 'theme/app_theme.dart';
import 'models/cart_model.dart';
import 'widgets/toast_stack.dart';
import 'widgets/app_background.dart';

void main() {
  runApp(const MyApp());
}

class NoGlowScrollBehavior extends MaterialScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CartModel(),
      child: MaterialApp(
        title: 'Gari Grill',
        theme: appTheme,
        scrollBehavior: NoGlowScrollBehavior(),
        home: const SplashScreen(),
        builder: (context, child) {
          return Stack(
            children: [
              const Positioned.fill(child: AppBackground()),
              if (child != null) child,
              const ToastStack(),
            ],
          );
        },
      ),
    );
  }
}

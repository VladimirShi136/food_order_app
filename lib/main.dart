import 'package:flutter/material.dart';
import 'package:food_order_app/screens/splash_screen.dart';
import 'package:provider/provider.dart';

import 'models/auth_model.dart';
import 'models/cart_model.dart';
import 'services/pocketbase_service.dart';
import 'theme/app_theme.dart';
import 'widgets/app_background.dart';
import 'widgets/toast_stack.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initPocketBase();
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartModel()),
        ChangeNotifierProvider(create: (_) => AuthModel()),
      ],
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'theme/app_theme.dart';
import 'models/cart_model.dart';
import 'screens/main_navigation_screen.dart';

void main() {
  runApp(const MyApp());
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
        home: const MainNavigationScreen(),
      ),
    );
  }
}

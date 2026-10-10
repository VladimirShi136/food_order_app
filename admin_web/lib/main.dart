import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

import 'screens/login_screen.dart';
import 'screens/orders_screen.dart';

const _background = Color(0xFF141414);
const _surface = Color(0xFF1E1E1E);
const _gold = Color(0xFFF5B301);

void main() {
  const baseUrl = String.fromEnvironment(
    'PB_URL',
    defaultValue: 'http://127.0.0.1:8090',
  );
  runApp(GariGrillAdminApp(client: PocketBase(baseUrl)));
}

class GariGrillAdminApp extends StatefulWidget {
  final PocketBase client;

  const GariGrillAdminApp({super.key, required this.client});

  @override
  State<GariGrillAdminApp> createState() => _GariGrillAdminAppState();
}

class _GariGrillAdminAppState extends State<GariGrillAdminApp> {
  bool _isSignedIn = false;

  @override
  void initState() {
    super.initState();
    _isSignedIn = widget.client.authStore.isValid;
  }

  void _onSignedIn() => setState(() => _isSignedIn = true);

  void _onSignedOut() {
    widget.client.authStore.clear();
    setState(() => _isSignedIn = false);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gari Grill — заказы',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: _background,
        colorScheme: const ColorScheme.dark(
          primary: _gold,
          secondary: _gold,
          surface: _surface,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: _surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: _gold,
            foregroundColor: _background,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: _isSignedIn
          ? OrdersScreen(client: widget.client, onSignOut: _onSignedOut)
          : LoginScreen(client: widget.client, onSignedIn: _onSignedIn),
    );
  }
}

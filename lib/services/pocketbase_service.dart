import 'package:pocketbase/pocketbase.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config.dart';

/// Единый клиент PocketBase на всё приложение.
/// Создаётся один раз в main() через [initPocketBase].
late final PocketBase pb;

/// Токен входа хранится на устройстве (shared_preferences),
/// поэтому пользователь остаётся авторизованным после перезапуска.
Future<void> initPocketBase() async {
  final prefs = await SharedPreferences.getInstance();

  final authStore = AsyncAuthStore(
    save: (String data) async => prefs.setString('pb_auth', data),
    clear: () async => prefs.remove('pb_auth'),
    initial: prefs.getString('pb_auth'),
  );

  pb = PocketBase(AppConfig.pocketBaseUrl, authStore: authStore);
}

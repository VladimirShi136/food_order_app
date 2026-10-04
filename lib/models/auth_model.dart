import 'package:flutter/foundation.dart';
import 'package:pocketbase/pocketbase.dart';

import '../services/pocketbase_service.dart';

/// Состояние авторизации. Читается через context.watch<AuthModel>().
class AuthModel extends ChangeNotifier {
  AuthModel() {
    pb.authStore.onChange.listen((_) => notifyListeners());
    _refreshOnStart();
  }

  bool get isLoggedIn => pb.authStore.isValid;

  RecordModel? get _user => pb.authStore.record;

  String get userId => _user?.id ?? '';
  String get name => _user?.getStringValue('name') ?? '';
  String get email => _user?.getStringValue('email') ?? '';
  String get phone => _user?.getStringValue('phone') ?? '';

  /// При старте обновляем токен: если пользователя удалили или токен
  /// недействителен — выходим. При отсутствии сети остаёмся авторизованными.
  Future<void> _refreshOnStart() async {
    if (!isLoggedIn) return;
    try {
      await pb.collection('users').authRefresh();
    } on ClientException catch (e) {
      if (e.statusCode == 401 || e.statusCode == 403 || e.statusCode == 404) {
        pb.authStore.clear();
      }
    }
  }

  Future<void> login(String email, String password) async {
    await pb.collection('users').authWithPassword(email, password);
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    String phone = '',
  }) async {
    await pb
        .collection('users')
        .create(
          body: {
            'email': email,
            'password': password,
            'passwordConfirm': password,
            'name': name,
            if (phone.isNotEmpty) 'phone': phone,
          },
        );
    await login(email, password);
  }

  void logout() => pb.authStore.clear();
}

/// Превращает ошибку PocketBase в понятный пользователю текст.
String authErrorMessage(Object error, {required bool registering}) {
  if (error is ClientException) {
    if (error.statusCode == 0) {
      return 'Нет связи с сервером. Проверьте интернет и попробуйте снова.';
    }
    if (error.statusCode == 400) {
      if (!registering) return 'Неверный email или пароль.';

      final data = error.response['data'];
      if (data is Map) {
        final email = data['email'];
        if (email is Map) {
          return email['code'] == 'validation_not_unique'
              ? 'Этот email уже зарегистрирован. Попробуйте войти.'
              : 'Проверьте правильность email.';
        }
        if (data['password'] is Map) {
          return 'Пароль должен содержать не менее 8 символов.';
        }
      }
      return 'Не удалось зарегистрироваться. Проверьте введённые данные.';
    }
    if (error.statusCode == 429) {
      return 'Слишком много попыток. Подождите немного.';
    }
  }
  return 'Что-то пошло не так. Попробуйте ещё раз.';
}

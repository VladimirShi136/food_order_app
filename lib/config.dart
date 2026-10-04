/// Настройки приложения.
///
/// Адрес сервера можно переопределить при запуске, не правя код:
///   flutter run --dart-define=PB_URL=http://192.168.1.50:8090
/// По умолчанию — адрес компьютера из Android-эмулятора.
/// Когда появится сервер, здесь будет https://ваш-домен.ru
class AppConfig {
  static const String pocketBaseUrl = String.fromEnvironment(
    'PB_URL',
    defaultValue: 'http://10.0.2.2:8090',
  );
}

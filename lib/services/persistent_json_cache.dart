import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class PersistentJsonCache {
  const PersistentJsonCache();

  Future<bool> write(String key, Object data) async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.setString(
      key,
      jsonEncode({
        'savedAt': DateTime.now().toUtc().toIso8601String(),
        'data': data,
      }),
    );
  }

  Future<CachedJsonEntry?> read(String key) async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = preferences.getString(key);
    if (encoded == null) return null;

    try {
      final decoded = jsonDecode(encoded);
      if (decoded is! Map<String, dynamic> ||
          decoded['savedAt'] is! String ||
          decoded['data'] == null) {
        await preferences.remove(key);
        return null;
      }
      final savedAt = DateTime.tryParse(decoded['savedAt'] as String);
      if (savedAt == null) {
        await preferences.remove(key);
        return null;
      }
      return CachedJsonEntry(
        data: decoded['data'],
        savedAt: savedAt.toLocal(),
      );
    } on FormatException {
      await preferences.remove(key);
      return null;
    }
  }
}

class CachedJsonEntry {
  final Object data;
  final DateTime savedAt;

  const CachedJsonEntry({required this.data, required this.savedAt});
}

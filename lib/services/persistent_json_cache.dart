import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cache_result.dart';

class PersistentJsonCache {
  const PersistentJsonCache();

  Future<CacheResult<T>> load<T>({
    required String key,
    required Duration freshness,
    required Future<T> Function() fetch,
    required Object Function(T value) encode,
    required T Function(Object data) decode,
    void Function(CacheResult<T> cached)? onCached,
    Duration timeout = const Duration(seconds: 6),
  }) async {
    final cached = await read(key);
    final cachedResult = cached == null
        ? null
        : _fromCache(cached, freshness, decode);
    if (cachedResult != null) onCached?.call(cachedResult);

    final connectivity = await Connectivity().checkConnectivity();

    if (connectivity.contains(ConnectivityResult.none)) {
      if (cachedResult == null) {
        throw StateError(
          'No internet connection and no cached data for "$key"',
        );
      }
      debugPrint('No internet connection; using cached data for "$key".');
      return _fromCache(cached!, freshness, decode, isOffline: true);
    }

    late final T value;
    try {
      value = await fetch().timeout(timeout);
    } catch (error, stackTrace) {
      if (cachedResult == null) Error.throwWithStackTrace(error, stackTrace);
      debugPrint('Refresh failed; using cached data for "$key": $error');
      return cachedResult;
    }

    final savedAt = DateTime.now();
    final saved = await write(key, encode(value));
    if (!saved) debugPrint('Unable to save cache for "$key".');
    return CacheResult(
      value: value,
      savedAt: savedAt,
      isFromCache: false,
      isStale: false,
    );
  }

  CacheResult<T> _fromCache<T>(
    CachedJsonEntry cached,
    Duration freshness,
    T Function(Object data) decode, {
    bool isOffline = false,
  }) {
    final age = DateTime.now().difference(cached.savedAt);
    return CacheResult(
      value: decode(cached.data),
      savedAt: cached.savedAt,
      isFromCache: true,
      isStale: age > freshness,
      isOffline: isOffline,
    );
  }

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
      return CachedJsonEntry(data: decoded['data'], savedAt: savedAt.toLocal());
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

class CacheResult<T> {
  final T value;
  final DateTime savedAt;
  final bool isFromCache;
  final bool isStale;
  final bool isOffline;

  const CacheResult({
    required this.value,
    required this.savedAt,
    required this.isFromCache,
    required this.isStale,
    this.isOffline = false,
  });
}

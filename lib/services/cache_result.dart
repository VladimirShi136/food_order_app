class CacheResult<T> {
  final T value;
  final DateTime savedAt;
  final bool isFromCache;
  final bool isStale;

  const CacheResult({
    required this.value,
    required this.savedAt,
    required this.isFromCache,
    required this.isStale,
  });
}

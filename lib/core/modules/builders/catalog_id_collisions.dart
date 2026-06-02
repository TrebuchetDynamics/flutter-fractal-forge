/// Replayable duplicate-ID report for declarative module catalogs.
///
/// Module registries may defensively de-duplicate IDs, but catalog sources
/// should expose collisions before candidates are silently dropped. Keeping the
/// first index and duplicate indexes together makes ingestion/order bugs
/// reproducible from the raw catalog list alone.
typedef CatalogIdOf<T> = String Function(T entry);

final class CatalogIdCollision<T> {
  CatalogIdCollision({
    required this.id,
    required this.firstIndex,
    required Iterable<int> duplicateIndexes,
    required Iterable<T> entries,
  })  : duplicateIndexes = List.unmodifiable(duplicateIndexes),
        entries = List.unmodifiable(entries) {
    assert(this.duplicateIndexes.isNotEmpty, 'collision requires duplicates');
    assert(this.entries.length == this.duplicateIndexes.length + 1,
        'entries must contain first entry plus duplicates');
  }

  final String id;
  final int firstIndex;
  final List<int> duplicateIndexes;
  final List<T> entries;

  List<int> get indexes => List.unmodifiable([
        firstIndex,
        ...duplicateIndexes,
      ]);

  /// Number of later candidates that a first-wins de-duplication pass drops.
  int get droppedCandidateCount => duplicateIndexes.length;
}

List<CatalogIdCollision<T>> findCatalogIdCollisions<T>(
  Iterable<T> entries,
  CatalogIdOf<T> idOf,
) {
  final indexesById = <String, List<int>>{};
  final entriesById = <String, List<T>>{};

  var index = 0;
  for (final entry in entries) {
    final id = idOf(entry);
    indexesById.putIfAbsent(id, () => <int>[]).add(index);
    entriesById.putIfAbsent(id, () => <T>[]).add(entry);
    index++;
  }

  return [
    for (final collision in indexesById.entries)
      if (collision.value.length > 1)
        CatalogIdCollision<T>(
          id: collision.key,
          firstIndex: collision.value.first,
          duplicateIndexes: collision.value.skip(1),
          entries: entriesById[collision.key]!,
        ),
  ];
}

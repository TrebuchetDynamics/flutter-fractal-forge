/// Generation token used to reject asynchronous shader loads that began before
/// a cache invalidation event.
class ShaderLoadEpoch {
  int _generation = 0;

  int capture() => _generation;

  bool isCurrent(int generation) => generation == _generation;

  void invalidate() {
    _generation++;
  }
}

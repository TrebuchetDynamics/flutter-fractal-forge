/// Pure policy for deciding whether the GPU renderer needs continuous frames.
abstract final class RendererTickerPolicy {
  static bool shouldTick({
    required bool animationEnabled,
    required bool moduleUsesTime,
    required bool fluidEffectActive,
    required bool paletteTransitionActive,
    required bool morphTransitionActive,
    required bool celebrationActive,
  }) {
    return animationEnabled &&
        (moduleUsesTime ||
            fluidEffectActive ||
            paletteTransitionActive ||
            morphTransitionActive ||
            celebrationActive);
  }
}

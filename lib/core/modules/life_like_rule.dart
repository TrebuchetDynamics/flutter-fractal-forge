/// B/S neighbor-count notation, using the shader's rounded 9-bit masks.
String lifeLikeRuleName(num birthMask, num survivalMask) {
  String digits(num mask) {
    if (!mask.isFinite) {
      throw ArgumentError.value(mask, 'mask', 'Must be finite');
    }
    final bits = (mask.clamp(0, 511) + 0.5).floor();
    return [
      for (var count = 0; count <= 8; count++)
        if ((bits & (1 << count)) != 0) count,
    ].join();
  }

  return 'B${digits(birthMask)}/S${digits(survivalMask)}';
}

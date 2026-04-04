import 'package:flutter/material.dart';

/// Color constants for thumbnail gradient fallbacks, organized by fractal category.
///
/// These constants replace hardcoded Color(0xFF...) values in
/// [ThumbnailFractalGradientPainter] to improve maintainability.
abstract final class ThumbnailColors {
  // ==========================================================================
  // Escape Time Colors
  // ==========================================================================

  /// Deep blue/purple background for escape-time fractals.
  static const Color escapeTimeBackground = Color(0xFF040820);

  /// Radial glow center color (bright blue-purple).
  static const Color escapeTimeGlowCenter = Color(0xFF3B1FA0);

  /// Radial glow middle color.
  static const Color escapeTimeGlowMid = Color(0xFF1A0A50);

  /// Radial glow edge color (matches background).
  static const Color escapeTimeGlowEdge = Color(0xFF040820);

  /// Small accent radial center (soft blue-white).
  static const Color escapeTimeAccentCenter = Color(0xCCBBDDFF);

  /// Small accent radial middle (blue-purple).
  static const Color escapeTimeAccentMid = Color(0x885599FF);

  /// Small accent radial edge (transparent deep blue).
  static const Color escapeTimeAccentEdge = Color(0x003311AA);

  /// Linear sweep start (transparent blue).
  static const Color escapeTimeSweepStart = Color(0x004488FF);

  /// Linear sweep middle (semi-transparent blue).
  static const Color escapeTimeSweepMid = Color(0x336699FF);

  /// Linear sweep end (transparent blue).
  static const Color escapeTimeSweepEnd = Color(0x004488FF);

  // ==========================================================================
  // Complex Visualization Colors
  // ==========================================================================

  /// Dark purple-black background for complex visualizations.
  static const Color complexVizBackground = Color(0xFF0D0015);

  /// Spectrum pink (rainbow sweep endpoint).
  static const Color complexVizPink = Color(0xFFFF0080);

  /// Spectrum orange.
  static const Color complexVizOrange = Color(0xFFFF6600);

  /// Spectrum yellow.
  static const Color complexVizYellow = Color(0xFFFFDD00);

  /// Spectrum green.
  static const Color complexVizGreen = Color(0xFF00FF88);

  /// Spectrum blue.
  static const Color complexVizBlue = Color(0xFF0088FF);

  /// Spectrum purple.
  static const Color complexVizPurple = Color(0xFF8800FF);

  /// Radial vignette transparent center.
  static const Color complexVizVignetteTransparent = Color(0x00000000);

  /// Radial vignette dark edge.
  static const Color complexVizVignetteDark = Color(0xAA000000);

  // ==========================================================================
  // Rational Maps Colors
  // ==========================================================================

  /// Dark red-brown background for rational maps.
  static const Color rationalMapsBackground = Color(0xFF1A0500);

  /// Radial glow center (bright orange).
  static const Color rationalMapsGlowCenter = Color(0xFFFF6B00);

  /// Radial glow middle (deep red).
  static const Color rationalMapsGlowMid = Color(0xFFCC2200);

  /// Radial glow edge (matches background).
  static const Color rationalMapsGlowEdge = Color(0xFF1A0500);

  /// Linear accent start (semi-transparent orange).
  static const Color rationalMapsAccentStart = Color(0x55FF9900);

  /// Linear accent middle transparent (orange).
  static const Color rationalMapsAccentMid = Color(0x00FF5500);

  /// Linear accent end (transparent red).
  static const Color rationalMapsAccentEnd = Color(0x33FF2200);

  // ==========================================================================
  // Attractor Colors
  // ==========================================================================

  /// Dark green background for attractors.
  static const Color attractorBackground = Color(0xFF010E06);

  /// Radial glow center (bright green).
  static const Color attractorGlowCenter = Color(0xFF00C864);

  /// Radial glow middle (teal-green).
  static const Color attractorGlowMid = Color(0xFF006644);

  /// Radial glow edge (matches background).
  static const Color attractorGlowEdge = Color(0xFF010E06);

  /// Linear accent start (semi-transparent cyan).
  static const Color attractorAccentStart = Color(0x4400E5CC);

  /// Linear accent middle transparent (teal).
  static const Color attractorAccentMid = Color(0x0000CC99);

  /// Linear accent end (semi-transparent teal).
  static const Color attractorAccentEnd = Color(0x2200AAAA);

  // ==========================================================================
  // Cellular Automata Colors
  // ==========================================================================

  /// Dark gray background for cellular automata.
  static const Color cellularBackground = Color(0xFF111111);

  /// Gradient top (medium gray).
  static const Color cellularGradientTop = Color(0xFF2E2E2E);

  /// Gradient bottom (matches background).
  static const Color cellularGradientBottom = Color(0xFF111111);

  /// Grid line color (very subtle white).
  static const Color cellularGridLine = Color(0x22FFFFFF);

  /// Cell accent color (subtle white highlight).
  static const Color cellularAccent = Color(0x44FFFFFF);

  // ==========================================================================
  // Rational Maps (alias for sweep categories)
  // ==========================================================================

  /// Alias for [complexVizPink] — used by rational maps sweep.
  static const Color rationalMapsSweepEndpoint = complexVizPink;
}

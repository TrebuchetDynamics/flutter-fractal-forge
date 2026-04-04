import 'package:flutter/material.dart';

/// Category accent color helper.
///
/// Returns the accent color for a given fractal category string.
Color categoryAccentColor(String category) {
  final cat = category.toLowerCase();
  if (cat.contains('escape')) return const Color(0xFF5B6FD4);
  if (cat.contains('complex')) return const Color(0xFF9B59B6);
  if (cat.contains('rational')) return const Color(0xFFE67E22);
  if (cat.contains('attract')) return const Color(0xFF27AE60);
  if (cat.contains('cellular') || cat.contains('automata')) {
    return const Color(0xFF7F8C8D);
  }
  return const Color(0xFF2980B9);
}

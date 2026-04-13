// GENERATED — DO NOT EDIT BY HAND.
import 'package:meta/meta.dart';

@immutable
class Citation {
  final String? author;
  final String? title;
  final int? year;
  final String url;
  const Citation({this.author, this.title, this.year, required this.url});
}

@immutable
class F0058ThreeScrollUnifiedPanMetadata {
  static const instance = F0058ThreeScrollUnifiedPanMetadata._();
  const F0058ThreeScrollUnifiedPanMetadata._();

  String get id => 'f0058_three_scroll_unified_pan';
  String get name => 'Three-Scroll Unified (Pan)';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'TSUCS',
    'three scroll',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'L. Pan et al.',
      title: 'A new three-scroll unified chaotic system',
      year: 2010,
      url: 'https://doi.org/10.1109/CINC.2010.5643913',
    ),
  ];
}

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
class F0812CuspMapMetadata {
  static const instance = F0812CuspMapMetadata._();
  const F0812CuspMapMetadata._();

  String get id => 'f0812_cusp_map';
  String get name => 'Cusp Map';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'A. Lasota, J. A. Yorke',
      title: 'On the existence of invariant measures for piecewise monotonic transformations',
      year: 1973,
      url: 'https://doi.org/10.2307/1996575',
    ),
  ];
}

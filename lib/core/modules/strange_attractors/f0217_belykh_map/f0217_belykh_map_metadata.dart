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
class F0217BelykhMapMetadata {
  static const instance = F0217BelykhMapMetadata._();
  const F0217BelykhMapMetadata._();

  String get id => 'f0217_belykh_map';
  String get name => 'Belykh Map';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'V. N. Belykh',
      title: 'Bifurcation of separatrices of a saddle point',
      year: 1980,
      url: 'https://en.wikipedia.org/wiki/Belykh_map',
    ),
  ];
}

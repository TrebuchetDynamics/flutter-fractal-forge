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
class F0007SchrDerSMethodMetadata {
  static const instance = F0007SchrDerSMethodMetadata._();
  const F0007SchrDerSMethodMetadata._();

  String get id => 'f0007_schr_der_s_method';
  String get name => 'Schröder&#39;s Method';
  String get category => 'Newton / Root-Finding';

  List<String> get aliases => const [
    'Schroder',
    'Schröder iteration',
    'Konig&#39;s method',
    'Modified Newton for multiple roots',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Ernst Schröder',
      title: 'Über unendlich viele Algorithmen zur Auflösung der Gleichungen',
      year: 1870,
      url: 'https://en.wikipedia.org/wiki/Schr%C3%B6der%27s_iteration',
    ),
  ];
}

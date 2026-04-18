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
class F0684PenroseP2KiteAndDartMetadata {
  static const instance = F0684PenroseP2KiteAndDartMetadata._();
  const F0684PenroseP2KiteAndDartMetadata._();

  String get id => 'f0684_penrose_p2_kite_and_dart';
  String get name => 'Penrose P2 Kite-and-Dart';
  String get category => 'Tiling & Aperiodic';

  List<String> get aliases => const [
    'Kite-Dart',
    'P2',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'R. Penrose',
      title: 'The Role of Aesthetics in Pure and Applied Mathematical Research',
      year: 1974,
      url: 'https://en.wikipedia.org/wiki/Penrose_tiling',
    ),
  ];
}

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
class F1088BelykhWideMetadata {
  static const instance = F1088BelykhWideMetadata._();
  const F1088BelykhWideMetadata._();

  String get id => 'f1088_belykh_wide';
  String get name => 'Belykh Wide';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Belykh a=2.0',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'V. N. Belykh',
      title: 'Models of discrete systems of phase synchronization',
      year: 1976,
      url: 'https://en.wikipedia.org/wiki/Belykh_map',
    ),
  ];
}

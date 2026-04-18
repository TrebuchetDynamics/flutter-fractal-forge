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
class F1087BelykhClassicMetadata {
  static const instance = F1087BelykhClassicMetadata._();
  const F1087BelykhClassicMetadata._();

  String get id => 'f1087_belykh_classic';
  String get name => 'Belykh Classic';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Belykh a=1.5',
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

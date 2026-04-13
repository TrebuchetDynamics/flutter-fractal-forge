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
class F0270NFlakeGeneralMetadata {
  static const instance = F0270NFlakeGeneralMetadata._();
  const F0270NFlakeGeneralMetadata._();

  String get id => 'f0270_n_flake_general';
  String get name => 'N-flake (general)';
  String get category => 'IFS &amp; Geometric Construction';

  List<String> get aliases => const [
    'polyflake',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Paul Bourke',
      title: 'n-flake',
      year: 2000,
      url: 'http://paulbourke.net/fractals/ifs/',
    ),
  ];
}

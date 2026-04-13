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
class F0290KleinianLimitSetMetadata {
  static const instance = F0290KleinianLimitSetMetadata._();
  const F0290KleinianLimitSetMetadata._();

  String get id => 'f0290_kleinian_limit_set';
  String get name => 'Kleinian Limit Set';
  String get category => 'IFS &amp; Geometric Construction';

  List<String> get aliases => const [
    'Kleinian limit',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'M. F. Barnsley',
      title: 'Fractals Everywhere',
      year: 1988,
      url: 'https://doi.org/10.1016/C2013-0-10335-2',
    ),
  ];
}

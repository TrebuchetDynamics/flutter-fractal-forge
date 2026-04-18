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
class F0992DotLifeB3S023Metadata {
  static const instance = F0992DotLifeB3S023Metadata._();
  const F0992DotLifeB3S023Metadata._();

  String get id => 'f0992_dot_life_b3_s023';
  String get name => 'Dot Life (B3/S023)';
  String get category => 'Cellular & Stochastic';

  List<String> get aliases => const [
    'B3-S023',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Mirek Wójtowicz',
      title: 'Mirek\'s Cellebration database',
      year: 1999,
      url: 'https://www.mirekw.com/ca/',
    ),
  ];
}

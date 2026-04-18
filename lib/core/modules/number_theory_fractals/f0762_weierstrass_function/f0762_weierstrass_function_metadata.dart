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
class F0762WeierstrassFunctionMetadata {
  static const instance = F0762WeierstrassFunctionMetadata._();
  const F0762WeierstrassFunctionMetadata._();

  String get id => 'f0762_weierstrass_function';
  String get name => 'Weierstrass Function';
  String get category => 'Number-Theory Fractals';

  List<String> get aliases => const [
    'Weierstrass',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'K. Weierstrass',
      title: 'Über continuirliche Functionen eines reellen Arguments, die für keinen Werth des letzeren einen bestimmten Differentialquotienten besitzen',
      year: 1872,
      url: 'https://mathworld.wolfram.com/WeierstrassFunction.html',
    ),
  ];
}

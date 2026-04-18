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
class F0988PseudoLifeB357S238Metadata {
  static const instance = F0988PseudoLifeB357S238Metadata._();
  const F0988PseudoLifeB357S238Metadata._();

  String get id => 'f0988_pseudo_life_b357_s238';
  String get name => 'Pseudo Life (B357/S238)';
  String get category => 'Cellular & Stochastic';

  List<String> get aliases => const [
    'pseudo-life',
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

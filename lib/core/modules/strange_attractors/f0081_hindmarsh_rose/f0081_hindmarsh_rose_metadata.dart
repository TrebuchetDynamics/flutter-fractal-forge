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
class F0081HindmarshRoseMetadata {
  static const instance = F0081HindmarshRoseMetadata._();
  const F0081HindmarshRoseMetadata._();

  String get id => 'f0081_hindmarsh_rose';
  String get name => 'Hindmarsh-Rose';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'J. L. Hindmarsh, R. M. Rose',
      title: 'A model of neuronal bursting using three coupled first order differential equations',
      year: 1984,
      url: 'https://doi.org/10.1098/rspb.1984.0024',
    ),
  ];
}

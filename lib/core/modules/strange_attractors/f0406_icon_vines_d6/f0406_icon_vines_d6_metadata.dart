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
class F0406IconVinesD6Metadata {
  static const instance = F0406IconVinesD6Metadata._();
  const F0406IconVinesD6Metadata._();

  String get id => 'f0406_icon_vines_d6';
  String get name => 'Icon — Vines D6';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Icon n=6 lam=-1.8',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'M. Field, M. Golubitsky',
      title: 'Symmetry in Chaos: A Search for Pattern in Mathematics, Art and Nature',
      year: 1992,
      url: 'https://doi.org/10.1093/oso/9780198536895.001.0001',
    ),
    Citation(
      author: 'Paul Bourke',
      title: 'Symmetric icons',
      year: 2005,
      url: 'http://paulbourke.net/fractals/symmetric/',
    ),
  ];
}

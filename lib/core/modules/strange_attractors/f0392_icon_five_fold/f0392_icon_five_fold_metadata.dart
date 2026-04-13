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
class F0392IconFiveFoldMetadata {
  static const instance = F0392IconFiveFoldMetadata._();
  const F0392IconFiveFoldMetadata._();

  String get id => 'f0392_icon_five_fold';
  String get name => 'Icon — Five-Fold';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Icon n=5 lam=-2.34',
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

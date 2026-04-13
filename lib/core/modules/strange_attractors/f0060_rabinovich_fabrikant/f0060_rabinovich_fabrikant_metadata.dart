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
class F0060RabinovichFabrikantMetadata {
  static const instance = F0060RabinovichFabrikantMetadata._();
  const F0060RabinovichFabrikantMetadata._();

  String get id => 'f0060_rabinovich_fabrikant';
  String get name => 'Rabinovich-Fabrikant';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'M. I. Rabinovich, A. L. Fabrikant',
      title: 'Stochastic self-modulation of waves in nonequilibrium media',
      year: 1979,
      url: 'https://link.springer.com/article/10.1007/BF01118570',
    ),
  ];
}

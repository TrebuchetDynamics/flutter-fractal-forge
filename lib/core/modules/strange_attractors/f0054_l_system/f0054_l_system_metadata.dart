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
class F0054LSystemMetadata {
  static const instance = F0054LSystemMetadata._();
  const F0054LSystemMetadata._();

  String get id => 'f0054_l_system';
  String get name => 'Lü System';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Lu system',
    'Lu-Chen system',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'J. Lü, G. Chen',
      title: 'A new chaotic attractor coined',
      year: 2002,
      url: 'https://doi.org/10.1142/S0218127402004620',
    ),
  ];
}

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
class F0073LiuChaoticSystemMetadata {
  static const instance = F0073LiuChaoticSystemMetadata._();
  const F0073LiuChaoticSystemMetadata._();

  String get id => 'f0073_liu_chaotic_system';
  String get name => 'Liu Chaotic System';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'C. Liu, T. Liu, L. Liu, K. Liu',
      title: 'A new chaotic attractor',
      year: 2004,
      url: 'https://doi.org/10.1016/j.chaos.2003.12.034',
    ),
  ];
}

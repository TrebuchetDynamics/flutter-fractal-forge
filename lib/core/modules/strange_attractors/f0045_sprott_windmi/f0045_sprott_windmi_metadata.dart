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
class F0045SprottWindmiMetadata {
  static const instance = F0045SprottWindmiMetadata._();
  const F0045SprottWindmiMetadata._();

  String get id => 'f0045_sprott_windmi';
  String get name => 'Sprott WINDMI';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Sprott-WINDMI',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'J. C. Sprott',
      title: 'Elegant Chaos: Algebraically Simple Chaotic Flows',
      year: 2010,
      url: 'https://sprott.physics.wisc.edu/pubs/paper356.pdf',
    ),
  ];
}

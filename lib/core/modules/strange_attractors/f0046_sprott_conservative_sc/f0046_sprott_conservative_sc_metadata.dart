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
class F0046SprottConservativeScMetadata {
  static const instance = F0046SprottConservativeScMetadata._();
  const F0046SprottConservativeScMetadata._();

  String get id => 'f0046_sprott_conservative_sc';
  String get name => 'Sprott Conservative SC';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Sprott-Conservative-SC',
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

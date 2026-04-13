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
class F0231HeighwayDragonLSystemMetadata {
  static const instance = F0231HeighwayDragonLSystemMetadata._();
  const F0231HeighwayDragonLSystemMetadata._();

  String get id => 'f0231_heighway_dragon_l_system';
  String get name => 'Heighway Dragon L-system';
  String get category => 'L-Systems &amp; Space-Filling';

  List<String> get aliases => const [
    'Heighway dragon',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Paul Bourke',
      title: 'Heighway Dragon L-system',
      year: 2002,
      url: 'http://paulbourke.net/fractals/lsys/',
    ),
    Citation(
      author: 'P. Prusinkiewicz, A. Lindenmayer',
      title: 'The Algorithmic Beauty of Plants',
      year: 1990,
      url: 'http://algorithmicbotany.org/papers/abop/abop.pdf',
    ),
  ];
}

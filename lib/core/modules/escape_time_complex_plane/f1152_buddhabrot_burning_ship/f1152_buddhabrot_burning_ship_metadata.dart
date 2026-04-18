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
class F1152BuddhabrotBurningShipMetadata {
  static const instance = F1152BuddhabrotBurningShipMetadata._();
  const F1152BuddhabrotBurningShipMetadata._();

  String get id => 'f1152_buddhabrot_burning_ship';
  String get name => 'Buddhabrot Burning Ship';
  String get category => 'Escape-Time (Complex Plane)';
  String get family => 'burning_ship';

  List<String> get aliases => const [
    'Burning Buddhabrot',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Lori Gardi (Melinda Green\'s adaptation)',
      title: 'The Buddhabrot Technique',
      year: 1993,
      url: 'http://superliminal.com/fractals/bbrot/bbrot.htm',
    ),
  ];
}

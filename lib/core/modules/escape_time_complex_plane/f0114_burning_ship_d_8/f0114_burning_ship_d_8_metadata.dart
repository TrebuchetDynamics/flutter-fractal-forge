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
class F0114BurningShipD8Metadata {
  static const instance = F0114BurningShipD8Metadata._();
  const F0114BurningShipD8Metadata._();

  String get id => 'f0114_burning_ship_d_8';
  String get name => 'Burning Ship d=8';
  String get category => 'Escape-Time (Complex Plane)';
  String get family => 'burning_ship';

  List<String> get aliases => const [
    'Burning Ship z^8',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Michael Michelitsch, Otto E. Rössler',
      title: 'The &#39;Burning Ship&#39; and its Quasi-Julia Sets',
      year: 1992,
      url: 'https://en.wikipedia.org/wiki/Burning_Ship_fractal',
    ),
  ];
}

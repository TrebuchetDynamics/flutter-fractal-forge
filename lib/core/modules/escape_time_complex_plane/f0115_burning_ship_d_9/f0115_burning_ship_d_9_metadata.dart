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
class F0115BurningShipD9Metadata {
  static const instance = F0115BurningShipD9Metadata._();
  const F0115BurningShipD9Metadata._();

  String get id => 'f0115_burning_ship_d_9';
  String get name => 'Burning Ship d=9';
  String get category => 'Escape-Time (Complex Plane)';
  String get family => 'burning_ship';

  List<String> get aliases => const [
    'Burning Ship z^9',
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

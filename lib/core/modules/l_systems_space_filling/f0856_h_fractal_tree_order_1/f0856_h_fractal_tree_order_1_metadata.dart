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
class F0856HFractalTreeOrder1Metadata {
  static const instance = F0856HFractalTreeOrder1Metadata._();
  const F0856HFractalTreeOrder1Metadata._();

  String get id => 'f0856_h_fractal_tree_order_1';
  String get name => 'H-Fractal Tree Order 1';
  String get category => 'L-Systems & Space-Filling';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Paul Bourke',
      title: 'H-fractal',
      year: 2002,
      url: 'http://paulbourke.net/fractals/lsys/',
    ),
  ];
}

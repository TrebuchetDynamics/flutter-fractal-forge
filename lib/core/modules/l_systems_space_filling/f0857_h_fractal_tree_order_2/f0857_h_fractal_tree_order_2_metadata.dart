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
class F0857HFractalTreeOrder2Metadata {
  static const instance = F0857HFractalTreeOrder2Metadata._();
  const F0857HFractalTreeOrder2Metadata._();

  String get id => 'f0857_h_fractal_tree_order_2';
  String get name => 'H-Fractal Tree Order 2';
  String get category => 'L-Systems & Space-Filling';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Paul Bourke',
      title: 'H-fractal-2',
      year: 2002,
      url: 'http://paulbourke.net/fractals/lsys/',
    ),
  ];
}

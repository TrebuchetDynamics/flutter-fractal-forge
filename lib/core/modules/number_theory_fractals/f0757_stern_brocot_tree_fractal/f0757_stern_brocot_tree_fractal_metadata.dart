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
class F0757SternBrocotTreeFractalMetadata {
  static const instance = F0757SternBrocotTreeFractalMetadata._();
  const F0757SternBrocotTreeFractalMetadata._();

  String get id => 'f0757_stern_brocot_tree_fractal';
  String get name => 'Stern-Brocot Tree Fractal';
  String get category => 'Number-Theory Fractals';

  List<String> get aliases => const [
    'Stern-Brocot',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'M. A. Stern',
      title: 'Über eine zahlentheoretische Funktion',
      year: 1858,
      url: 'https://mathworld.wolfram.com/Stern-BrocotTree.html',
    ),
    Citation(
      author: 'A. Brocot',
      title: 'Calcul des rouages par approximation',
      year: 1861,
      url: 'https://mathworld.wolfram.com/Stern-BrocotTree.html',
    ),
  ];
}

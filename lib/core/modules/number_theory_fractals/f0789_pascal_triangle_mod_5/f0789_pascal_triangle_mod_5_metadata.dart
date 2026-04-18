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
class F0789PascalTriangleMod5Metadata {
  static const instance = F0789PascalTriangleMod5Metadata._();
  const F0789PascalTriangleMod5Metadata._();

  String get id => 'f0789_pascal_triangle_mod_5';
  String get name => 'Pascal Triangle Mod 5';
  String get category => 'Number-Theory Fractals';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'E. Lucas',
      title: 'Théorie des Fonctions Numériques',
      year: 1878,
      url: 'https://mathworld.wolfram.com/LucasTheorem.html',
    ),
  ];
}

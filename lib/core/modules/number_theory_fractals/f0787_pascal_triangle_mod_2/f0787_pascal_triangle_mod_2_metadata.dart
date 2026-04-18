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
class F0787PascalTriangleMod2Metadata {
  static const instance = F0787PascalTriangleMod2Metadata._();
  const F0787PascalTriangleMod2Metadata._();

  String get id => 'f0787_pascal_triangle_mod_2';
  String get name => 'Pascal Triangle Mod 2';
  String get category => 'Number-Theory Fractals';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'E. Lucas',
      title: 'Théorie des Fonctions Numériques Simplement Périodiques',
      year: 1878,
      url: 'https://mathworld.wolfram.com/LucasTheorem.html',
    ),
  ];
}

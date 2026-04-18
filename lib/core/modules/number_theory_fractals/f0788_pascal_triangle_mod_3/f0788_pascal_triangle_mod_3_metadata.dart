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
class F0788PascalTriangleMod3Metadata {
  static const instance = F0788PascalTriangleMod3Metadata._();
  const F0788PascalTriangleMod3Metadata._();

  String get id => 'f0788_pascal_triangle_mod_3';
  String get name => 'Pascal Triangle Mod 3';
  String get category => 'Number-Theory Fractals';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'E. Lucas',
      title: 'Sur les congruences des nombres eulériens',
      year: 1878,
      url: 'https://mathworld.wolfram.com/LucasTheorem.html',
    ),
  ];
}

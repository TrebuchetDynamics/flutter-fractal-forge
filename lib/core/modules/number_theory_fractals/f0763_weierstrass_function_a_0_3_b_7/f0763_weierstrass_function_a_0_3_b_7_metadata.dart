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
class F0763WeierstrassFunctionA03B7Metadata {
  static const instance = F0763WeierstrassFunctionA03B7Metadata._();
  const F0763WeierstrassFunctionA03B7Metadata._();

  String get id => 'f0763_weierstrass_function_a_0_3_b_7';
  String get name => 'Weierstrass Function (a=0.3, b=7)';
  String get category => 'Number-Theory Fractals';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'G. H. Hardy',
      title: 'Weierstrass\'s non-differentiable function',
      year: 1916,
      url: 'https://doi.org/10.1090/S0002-9947-1916-1501068-6',
    ),
  ];
}

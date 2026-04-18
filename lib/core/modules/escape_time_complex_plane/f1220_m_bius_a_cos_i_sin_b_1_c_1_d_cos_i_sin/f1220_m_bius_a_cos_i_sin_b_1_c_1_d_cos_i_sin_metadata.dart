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
class F1220MBiusACosISinB1C1DCosISinMetadata {
  static const instance = F1220MBiusACosISinB1C1DCosISinMetadata._();
  const F1220MBiusACosISinB1C1DCosISinMetadata._();

  String get id => 'f1220_m_bius_a_cos_i_sin_b_1_c_1_d_cos_i_sin';
  String get name => 'Möbius (a=cos+i sin / b=1 / c=1 / d=cos-i sin)';
  String get category => 'Escape-Time (Complex Plane)';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'L. Carleson, T. W. Gamelin',
      title: 'Complex Dynamics',
      year: 1993,
      url: 'https://doi.org/10.1007/978-1-4612-4364-9',
    ),
  ];
}

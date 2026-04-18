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
class F1218MBiusA1IB1C1D1IMetadata {
  static const instance = F1218MBiusA1IB1C1D1IMetadata._();
  const F1218MBiusA1IB1C1D1IMetadata._();

  String get id => 'f1218_m_bius_a_1_i_b_1_c_1_d_1_i';
  String get name => 'Möbius (a=1+i b=1 c=1 d=1-i)';
  String get category => 'Escape-Time (Complex Plane)';

  List<String> get aliases => const [
    'Mobius 1',
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

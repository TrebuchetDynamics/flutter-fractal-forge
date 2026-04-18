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
class F1219MBiusA2B1C1D2Metadata {
  static const instance = F1219MBiusA2B1C1D2Metadata._();
  const F1219MBiusA2B1C1D2Metadata._();

  String get id => 'f1219_m_bius_a_2_b_1_c_1_d_2';
  String get name => 'Möbius (a=2 b=1 c=1 d=2)';
  String get category => 'Escape-Time (Complex Plane)';

  List<String> get aliases => const [
    'Mobius 2',
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

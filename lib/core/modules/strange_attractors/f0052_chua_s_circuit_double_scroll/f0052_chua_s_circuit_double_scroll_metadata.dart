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
class F0052ChuaSCircuitDoubleScrollMetadata {
  static const instance = F0052ChuaSCircuitDoubleScrollMetadata._();
  const F0052ChuaSCircuitDoubleScrollMetadata._();

  String get id => 'f0052_chua_s_circuit_double_scroll';
  String get name => 'Chua&#39;s Circuit (double scroll)';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Chua double scroll',
    'Chua circuit',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'T. Matsumoto',
      title: 'A chaotic attractor from Chua&#39;s circuit',
      year: 1984,
      url: 'https://doi.org/10.1109/TCS.1984.1085459',
    ),
  ];
}

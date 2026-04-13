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
class F0078YuWangMetadata {
  static const instance = F0078YuWangMetadata._();
  const F0078YuWangMetadata._();

  String get id => 'f0078_yu_wang';
  String get name => 'Yu-Wang';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'F. Yu, C. Wang',
      title: 'A novel three-dimensional autonomous chaotic system',
      year: 2012,
      url: 'https://doi.org/10.1007/s11071-012-0439-x',
    ),
  ];
}

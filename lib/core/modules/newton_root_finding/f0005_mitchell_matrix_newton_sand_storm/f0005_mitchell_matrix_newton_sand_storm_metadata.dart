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
class F0005MitchellMatrixNewtonSandStormMetadata {
  static const instance = F0005MitchellMatrixNewtonSandStormMetadata._();
  const F0005MitchellMatrixNewtonSandStormMetadata._();

  String get id => 'f0005_mitchell_matrix_newton_sand_storm';
  String get name => 'Mitchell Matrix Newton (Sand Storm)';
  String get category => 'Newton / Root-Finding';

  List<String> get aliases => const [
    'Matrix Newton',
    '2x2 System Newton',
    'Sand Storm',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Kerry Mitchell',
      title: 'Fun with Newton&#39;s Method',
      year: 2019,
      url: 'https://archive.bridgesmathart.org/2019/bridges2019-271.html',
    ),
  ];
}

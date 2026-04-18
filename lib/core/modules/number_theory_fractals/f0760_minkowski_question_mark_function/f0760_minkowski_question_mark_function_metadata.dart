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
class F0760MinkowskiQuestionMarkFunctionMetadata {
  static const instance = F0760MinkowskiQuestionMarkFunctionMetadata._();
  const F0760MinkowskiQuestionMarkFunctionMetadata._();

  String get id => 'f0760_minkowski_question_mark_function';
  String get name => 'Minkowski Question Mark Function';
  String get category => 'Number-Theory Fractals';

  List<String> get aliases => const [
    '?(x)',
    'Minkowski ?',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'H. Minkowski',
      title: 'Zur Geometrie der Zahlen',
      year: 1904,
      url: 'https://mathworld.wolfram.com/MinkowskiQuestionMarkFunction.html',
    ),
  ];
}

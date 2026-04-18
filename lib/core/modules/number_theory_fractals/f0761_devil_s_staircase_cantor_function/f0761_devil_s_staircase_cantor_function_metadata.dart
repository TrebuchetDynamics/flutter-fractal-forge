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
class F0761DevilSStaircaseCantorFunctionMetadata {
  static const instance = F0761DevilSStaircaseCantorFunctionMetadata._();
  const F0761DevilSStaircaseCantorFunctionMetadata._();

  String get id => 'f0761_devil_s_staircase_cantor_function';
  String get name => 'Devil\'s Staircase (Cantor Function)';
  String get category => 'Number-Theory Fractals';

  List<String> get aliases => const [
    'Cantor function',
    'Devil\'s staircase',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'G. Cantor',
      title: 'De la puissance des ensembles parfaits de points',
      year: 1884,
      url: 'https://mathworld.wolfram.com/CantorFunction.html',
    ),
  ];
}

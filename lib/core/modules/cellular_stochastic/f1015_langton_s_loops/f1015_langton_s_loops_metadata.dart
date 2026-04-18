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
class F1015LangtonSLoopsMetadata {
  static const instance = F1015LangtonSLoopsMetadata._();
  const F1015LangtonSLoopsMetadata._();

  String get id => 'f1015_langton_s_loops';
  String get name => 'Langton\'s Loops';
  String get category => 'Cellular & Stochastic';

  List<String> get aliases => const [
    'Langton loops',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'C. Langton',
      title: 'Self-reproduction in cellular automata',
      year: 1984,
      url: 'https://doi.org/10.1016/0167-2789(84)90256-2',
    ),
  ];
}

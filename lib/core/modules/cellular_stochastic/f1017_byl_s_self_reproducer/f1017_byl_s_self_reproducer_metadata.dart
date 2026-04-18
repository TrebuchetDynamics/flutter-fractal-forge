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
class F1017BylSSelfReproducerMetadata {
  static const instance = F1017BylSSelfReproducerMetadata._();
  const F1017BylSSelfReproducerMetadata._();

  String get id => 'f1017_byl_s_self_reproducer';
  String get name => 'Byl\'s Self-Reproducer';
  String get category => 'Cellular & Stochastic';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'J. Byl',
      title: 'Self-reproduction in small cellular automata',
      year: 1989,
      url: 'https://doi.org/10.1016/0167-2789(89)90185-5',
    ),
  ];
}

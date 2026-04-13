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
class F0067ArneodoAttractorMetadata {
  static const instance = F0067ArneodoAttractorMetadata._();
  const F0067ArneodoAttractorMetadata._();

  String get id => 'f0067_arneodo_attractor';
  String get name => 'Arneodo Attractor';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Arneodo-Coullet-Tresser',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'A. Arneodo, P. Coullet, C. Tresser',
      title: 'Possible new strange attractors with spiral structure',
      year: 1981,
      url: 'https://doi.org/10.1007/BF01208379',
    ),
  ];
}

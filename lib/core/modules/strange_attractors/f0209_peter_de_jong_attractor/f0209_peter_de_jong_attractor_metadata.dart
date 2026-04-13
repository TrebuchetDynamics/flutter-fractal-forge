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
class F0209PeterDeJongAttractorMetadata {
  static const instance = F0209PeterDeJongAttractorMetadata._();
  const F0209PeterDeJongAttractorMetadata._();

  String get id => 'f0209_peter_de_jong_attractor';
  String get name => 'Peter de Jong Attractor';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Peter de Jong',
      title: 'Strange attractors catalog',
      year: 1990,
      url: 'https://paulbourke.net/fractals/peterdejong/',
    ),
  ];
}

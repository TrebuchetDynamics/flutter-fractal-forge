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
class F0210SvenssonAttractorMetadata {
  static const instance = F0210SvenssonAttractorMetadata._();
  const F0210SvenssonAttractorMetadata._();

  String get id => 'f0210_svensson_attractor';
  String get name => 'Svensson Attractor';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Johnny Svensson via Paul Bourke',
      title: 'Svensson Attractor',
      year: 2005,
      url: 'https://paulbourke.net/fractals/peterdejong/',
    ),
  ];
}

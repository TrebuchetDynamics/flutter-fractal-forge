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
class F0370DeJongClassicMetadata {
  static const instance = F0370DeJongClassicMetadata._();
  const F0370DeJongClassicMetadata._();

  String get id => 'f0370_de_jong_classic';
  String get name => 'de Jong Classic';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'de Jong a=1.4 b=-2.3 c=2.4 d=-2.1',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Peter de Jong / Clifford Pickover',
      title: 'Symmetric de Jong attractors',
      year: 1988,
      url: 'http://paulbourke.net/fractals/peterdejong/',
    ),
  ];
}

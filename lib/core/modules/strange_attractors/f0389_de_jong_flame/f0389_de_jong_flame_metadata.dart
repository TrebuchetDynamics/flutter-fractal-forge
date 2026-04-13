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
class F0389DeJongFlameMetadata {
  static const instance = F0389DeJongFlameMetadata._();
  const F0389DeJongFlameMetadata._();

  String get id => 'f0389_de_jong_flame';
  String get name => 'de Jong Flame';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'de Jong a=1.4 b=1.56 c=1.4 d=-6.56',
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

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
class F0375DeJongWhirlpoolMetadata {
  static const instance = F0375DeJongWhirlpoolMetadata._();
  const F0375DeJongWhirlpoolMetadata._();

  String get id => 'f0375_de_jong_whirlpool';
  String get name => 'de Jong Whirlpool';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'de Jong a=-0.827 b=-1.637 c=1.659 d=-0.943',
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

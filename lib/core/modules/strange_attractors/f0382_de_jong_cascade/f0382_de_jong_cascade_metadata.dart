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
class F0382DeJongCascadeMetadata {
  static const instance = F0382DeJongCascadeMetadata._();
  const F0382DeJongCascadeMetadata._();

  String get id => 'f0382_de_jong_cascade';
  String get name => 'de Jong Cascade';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'de Jong a=0.97 b=-1.899 c=1.381 d=-1.506',
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

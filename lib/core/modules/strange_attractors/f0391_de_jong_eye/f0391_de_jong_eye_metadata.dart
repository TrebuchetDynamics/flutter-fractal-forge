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
class F0391DeJongEyeMetadata {
  static const instance = F0391DeJongEyeMetadata._();
  const F0391DeJongEyeMetadata._();

  String get id => 'f0391_de_jong_eye';
  String get name => 'de Jong Eye';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'de Jong a=2.879879 b=-0.765145 c=-0.966918 d=0.744728',
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

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
class F1048SvenssonEyeMetadata {
  static const instance = F1048SvenssonEyeMetadata._();
  const F1048SvenssonEyeMetadata._();

  String get id => 'f1048_svensson_eye';
  String get name => 'Svensson Eye';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Svensson a=-2.0 b=-2.0 c=-1.2 d=2.0',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Johnny Svensson / Paul Bourke',
      title: 'Svensson attractor',
      year: 2001,
      url: 'http://paulbourke.net/fractals/peterdejong/',
    ),
  ];
}

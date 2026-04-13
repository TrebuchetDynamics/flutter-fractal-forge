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
class F0287LVyCCurveIfsMetadata {
  static const instance = F0287LVyCCurveIfsMetadata._();
  const F0287LVyCCurveIfsMetadata._();

  String get id => 'f0287_l_vy_c_curve_ifs';
  String get name => 'Lévy C Curve IFS';
  String get category => 'IFS &amp; Geometric Construction';

  List<String> get aliases => const [
    'Levy C',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Paul Bourke',
      title: 'Levy C IFS',
      year: 2000,
      url: 'http://paulbourke.net/fractals/ifs/',
    ),
  ];
}

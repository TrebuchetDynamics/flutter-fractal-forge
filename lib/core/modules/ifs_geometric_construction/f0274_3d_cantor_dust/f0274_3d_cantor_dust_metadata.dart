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
class F02743dCantorDustMetadata {
  static const instance = F02743dCantorDustMetadata._();
  const F02743dCantorDustMetadata._();

  String get id => 'f0274_3d_cantor_dust';
  String get name => '3D Cantor Dust';
  String get category => 'IFS &amp; Geometric Construction';

  List<String> get aliases => const [
    'Cantor cube',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Paul Bourke',
      title: '3D Cantor dust',
      year: 2000,
      url: 'http://paulbourke.net/fractals/ifs/',
    ),
  ];
}

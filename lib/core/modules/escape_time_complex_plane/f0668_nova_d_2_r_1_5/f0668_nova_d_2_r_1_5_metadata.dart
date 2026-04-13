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
class F0668NovaD2R15Metadata {
  static const instance = F0668NovaD2R15Metadata._();
  const F0668NovaD2R15Metadata._();

  String get id => 'f0668_nova_d_2_r_1_5';
  String get name => 'Nova d=2 r=1.5';
  String get category => 'Escape-Time (Complex Plane)';

  List<String> get aliases => const [
    'Nova d=2 r=1.5',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Paul Bourke',
      title: 'Nova fractals',
      year: 2002,
      url: 'http://paulbourke.net/fractals/nova/',
    ),
  ];
}

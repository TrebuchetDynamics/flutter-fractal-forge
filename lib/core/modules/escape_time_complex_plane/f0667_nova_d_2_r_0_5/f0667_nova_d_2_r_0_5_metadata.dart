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
class F0667NovaD2R05Metadata {
  static const instance = F0667NovaD2R05Metadata._();
  const F0667NovaD2R05Metadata._();

  String get id => 'f0667_nova_d_2_r_0_5';
  String get name => 'Nova d=2 r=0.5';
  String get category => 'Escape-Time (Complex Plane)';

  List<String> get aliases => const [
    'Nova d=2 r=0.5',
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

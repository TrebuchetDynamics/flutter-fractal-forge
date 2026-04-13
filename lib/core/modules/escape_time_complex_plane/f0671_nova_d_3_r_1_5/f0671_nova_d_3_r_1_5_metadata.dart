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
class F0671NovaD3R15Metadata {
  static const instance = F0671NovaD3R15Metadata._();
  const F0671NovaD3R15Metadata._();

  String get id => 'f0671_nova_d_3_r_1_5';
  String get name => 'Nova d=3 r=1.5';
  String get category => 'Escape-Time (Complex Plane)';

  List<String> get aliases => const [
    'Nova d=3 r=1.5',
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

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
class F0682NovaD3CSweepRightMetadata {
  static const instance = F0682NovaD3CSweepRightMetadata._();
  const F0682NovaD3CSweepRightMetadata._();

  String get id => 'f0682_nova_d_3_c_sweep_right';
  String get name => 'Nova d=3 c-sweep right';
  String get category => 'Escape-Time (Complex Plane)';

  List<String> get aliases => const [
    'Nova d=3 r=1.0',
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

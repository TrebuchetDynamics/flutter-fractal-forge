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
class F0681NovaD3CSweepLeftMetadata {
  static const instance = F0681NovaD3CSweepLeftMetadata._();
  const F0681NovaD3CSweepLeftMetadata._();

  String get id => 'f0681_nova_d_3_c_sweep_left';
  String get name => 'Nova d=3 c-sweep left';
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

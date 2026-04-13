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
class F0589JuliabulbN3Metadata {
  static const instance = F0589JuliabulbN3Metadata._();
  const F0589JuliabulbN3Metadata._();

  String get id => 'f0589_juliabulb_n_3';
  String get name => 'Juliabulb n=3';
  String get category => '3D Raymarching & Hypercomplex';

  List<String> get aliases => const [
    'Juliabulb n=3 c=(0.2, 0.3, -0.1)',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'D. White, P. Nylander',
      title: 'Mandelbulb (web page)',
      year: 2009,
      url: 'http://www.skytopia.com/project/fractal/mandelbulb.html',
    ),
  ];
}

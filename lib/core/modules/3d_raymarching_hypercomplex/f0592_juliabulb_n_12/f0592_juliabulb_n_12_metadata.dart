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
class F0592JuliabulbN12Metadata {
  static const instance = F0592JuliabulbN12Metadata._();
  const F0592JuliabulbN12Metadata._();

  String get id => 'f0592_juliabulb_n_12';
  String get name => 'Juliabulb n=12';
  String get category => '3D Raymarching & Hypercomplex';

  List<String> get aliases => const [
    'Juliabulb n=12 c=(-0.3, 0.1, 0.2)',
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

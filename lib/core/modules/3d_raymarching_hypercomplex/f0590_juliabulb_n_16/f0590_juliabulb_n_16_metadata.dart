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
class F0590JuliabulbN16Metadata {
  static const instance = F0590JuliabulbN16Metadata._();
  const F0590JuliabulbN16Metadata._();

  String get id => 'f0590_juliabulb_n_16';
  String get name => 'Juliabulb n=16';
  String get category => '3D Raymarching & Hypercomplex';

  List<String> get aliases => const [
    'Juliabulb n=16 c=(0.0, 0.0, 0.4)',
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

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
class F0587JuliabulbN8ClassicMetadata {
  static const instance = F0587JuliabulbN8ClassicMetadata._();
  const F0587JuliabulbN8ClassicMetadata._();

  String get id => 'f0587_juliabulb_n_8_classic';
  String get name => 'Juliabulb n=8 (classic)';
  String get category => '3D Raymarching & Hypercomplex';

  List<String> get aliases => const [
    'Juliabulb n=8 c=(0.1, 0.4, -0.2)',
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

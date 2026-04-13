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
class F0588JuliabulbN8BranchingMetadata {
  static const instance = F0588JuliabulbN8BranchingMetadata._();
  const F0588JuliabulbN8BranchingMetadata._();

  String get id => 'f0588_juliabulb_n_8_branching';
  String get name => 'Juliabulb n=8 (branching)';
  String get category => '3D Raymarching & Hypercomplex';

  List<String> get aliases => const [
    'Juliabulb n=8 c=(-0.5, 0.2, 0.3)',
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

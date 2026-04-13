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
class F0012NovaFractalMetadata {
  static const instance = F0012NovaFractalMetadata._();
  const F0012NovaFractalMetadata._();

  String get id => 'f0012_nova_fractal';
  String get name => 'Nova Fractal';
  String get category => 'Newton / Root-Finding';

  List<String> get aliases => const [
    'Nova',
    'Damien Jones Nova',
    'Newton with c-offset',
    'Relaxed Newton',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Damien Jones',
      title: 'Nova Fractals',
      year: 1995,
      url: 'http://paulbourke.net/fractals/newtonraphson/',
    ),
  ];
}

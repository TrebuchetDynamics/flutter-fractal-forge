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
class F0742BelousovZhabotinskyContinuousMetadata {
  static const instance = F0742BelousovZhabotinskyContinuousMetadata._();
  const F0742BelousovZhabotinskyContinuousMetadata._();

  String get id => 'f0742_belousov_zhabotinsky_continuous';
  String get name => 'Belousov-Zhabotinsky (Continuous)';
  String get category => 'Reaction-Diffusion & Chemical';

  List<String> get aliases => const [
    'BZ reaction',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'A. N. Zaikin, A. M. Zhabotinsky',
      title: 'Concentration wave propagation in two-dimensional liquid-phase self-oscillating systems',
      year: 1970,
      url: 'https://doi.org/10.1038/225535b0',
    ),
  ];
}

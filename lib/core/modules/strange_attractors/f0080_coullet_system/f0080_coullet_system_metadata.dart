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
class F0080CoulletSystemMetadata {
  static const instance = F0080CoulletSystemMetadata._();
  const F0080CoulletSystemMetadata._();

  String get id => 'f0080_coullet_system';
  String get name => 'Coullet System';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'P. Coullet, C. Tresser',
      title: 'Iterations d&#39;endomorphismes et groupe de renormalisation',
      year: 1978,
      url: 'https://doi.org/10.1051/jphyscol:1978517',
    ),
  ];
}

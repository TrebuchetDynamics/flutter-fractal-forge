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
class F0753MeinhardtGiererActivatorInhibitorMetadata {
  static const instance = F0753MeinhardtGiererActivatorInhibitorMetadata._();
  const F0753MeinhardtGiererActivatorInhibitorMetadata._();

  String get id => 'f0753_meinhardt_gierer_activator_inhibitor';
  String get name => 'Meinhardt-Gierer Activator-Inhibitor';
  String get category => 'Reaction-Diffusion & Chemical';

  List<String> get aliases => const [
    'Meinhardt-Gierer',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'A. Gierer, H. Meinhardt',
      title: 'A theory of biological pattern formation',
      year: 1972,
      url: 'https://doi.org/10.1007/BF00289234',
    ),
  ];
}

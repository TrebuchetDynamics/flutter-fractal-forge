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
class F0750BrusselatorHopfMetadata {
  static const instance = F0750BrusselatorHopfMetadata._();
  const F0750BrusselatorHopfMetadata._();

  String get id => 'f0750_brusselator_hopf';
  String get name => 'Brusselator Hopf';
  String get category => 'Reaction-Diffusion & Chemical';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'I. Prigogine, R. Lefever',
      title: 'Symmetry breaking instabilities in dissipative systems II',
      year: 1968,
      url: 'https://doi.org/10.1063/1.1668896',
    ),
  ];
}

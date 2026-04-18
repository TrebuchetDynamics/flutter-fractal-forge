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
class F0740TuringStripesAnisotropicMetadata {
  static const instance = F0740TuringStripesAnisotropicMetadata._();
  const F0740TuringStripesAnisotropicMetadata._();

  String get id => 'f0740_turing_stripes_anisotropic';
  String get name => 'Turing Stripes (Anisotropic)';
  String get category => 'Reaction-Diffusion & Chemical';

  List<String> get aliases => const [
    'Turing stripes',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'A. M. Turing',
      title: 'The chemical basis of morphogenesis',
      year: 1952,
      url: 'https://doi.org/10.1098/rstb.1952.0012',
    ),
  ];
}

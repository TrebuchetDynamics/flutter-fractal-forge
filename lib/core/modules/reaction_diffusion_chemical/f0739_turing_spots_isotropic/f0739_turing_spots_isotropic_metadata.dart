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
class F0739TuringSpotsIsotropicMetadata {
  static const instance = F0739TuringSpotsIsotropicMetadata._();
  const F0739TuringSpotsIsotropicMetadata._();

  String get id => 'f0739_turing_spots_isotropic';
  String get name => 'Turing Spots (Isotropic)';
  String get category => 'Reaction-Diffusion & Chemical';

  List<String> get aliases => const [
    'Turing pattern',
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

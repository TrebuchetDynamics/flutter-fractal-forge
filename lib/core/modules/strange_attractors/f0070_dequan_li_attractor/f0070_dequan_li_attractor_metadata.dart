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
class F0070DequanLiAttractorMetadata {
  static const instance = F0070DequanLiAttractorMetadata._();
  const F0070DequanLiAttractorMetadata._();

  String get id => 'f0070_dequan_li_attractor';
  String get name => 'Dequan Li Attractor';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'D. Li',
      title: 'A three-scroll chaotic attractor',
      year: 2008,
      url: 'https://doi.org/10.1016/j.physleta.2007.05.040',
    ),
  ];
}

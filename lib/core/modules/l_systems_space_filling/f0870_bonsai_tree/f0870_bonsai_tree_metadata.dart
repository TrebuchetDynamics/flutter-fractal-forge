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
class F0870BonsaiTreeMetadata {
  static const instance = F0870BonsaiTreeMetadata._();
  const F0870BonsaiTreeMetadata._();

  String get id => 'f0870_bonsai_tree';
  String get name => 'Bonsai Tree';
  String get category => 'L-Systems & Space-Filling';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Paul Bourke',
      title: 'Bonsai',
      year: 2002,
      url: 'http://paulbourke.net/fractals/lsys/',
    ),
  ];
}

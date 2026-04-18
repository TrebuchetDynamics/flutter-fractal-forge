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
class F1062TylerFlowerMetadata {
  static const instance = F1062TylerFlowerMetadata._();
  const F1062TylerFlowerMetadata._();

  String get id => 'f1062_tyler_flower';
  String get name => 'Tyler Flower';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Tyler a=2.0 b=0.7',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Tim Tyler / Paul Bourke',
      title: 'Tyler attractor',
      year: 2003,
      url: 'http://paulbourke.net/fractals/tyler/',
    ),
  ];
}

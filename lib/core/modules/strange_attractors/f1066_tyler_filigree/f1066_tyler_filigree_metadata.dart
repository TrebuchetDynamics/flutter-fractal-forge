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
class F1066TylerFiligreeMetadata {
  static const instance = F1066TylerFiligreeMetadata._();
  const F1066TylerFiligreeMetadata._();

  String get id => 'f1066_tyler_filigree';
  String get name => 'Tyler Filigree';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Tyler a=1.8 b=-0.6',
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

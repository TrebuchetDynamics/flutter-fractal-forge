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
class F1063TylerStormMetadata {
  static const instance = F1063TylerStormMetadata._();
  const F1063TylerStormMetadata._();

  String get id => 'f1063_tyler_storm';
  String get name => 'Tyler Storm';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Tyler a=2.5 b=0.1',
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

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
class F1068TylerWebMetadata {
  static const instance = F1068TylerWebMetadata._();
  const F1068TylerWebMetadata._();

  String get id => 'f1068_tyler_web';
  String get name => 'Tyler Web';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Tyler a=1.9 b=0.0',
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

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
class F1208NovaZ31Metadata {
  static const instance = F1208NovaZ31Metadata._();
  const F1208NovaZ31Metadata._();

  String get id => 'f1208_nova_z_3_1';
  String get name => 'Nova z^3 - 1';
  String get category => 'Newton / Root-Finding';

  List<String> get aliases => const [
    'Nova cubic',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Paul Bourke',
      title: 'Nova fractals',
      year: 2002,
      url: 'http://paulbourke.net/fractals/nova/',
    ),
  ];
}

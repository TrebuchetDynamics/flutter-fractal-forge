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
class F1214NovaZ5Z21Metadata {
  static const instance = F1214NovaZ5Z21Metadata._();
  const F1214NovaZ5Z21Metadata._();

  String get id => 'f1214_nova_z_5_z_2_1';
  String get name => 'Nova z^5 + z^2 - 1';
  String get category => 'Newton / Root-Finding';

  List<String> get aliases => const [
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

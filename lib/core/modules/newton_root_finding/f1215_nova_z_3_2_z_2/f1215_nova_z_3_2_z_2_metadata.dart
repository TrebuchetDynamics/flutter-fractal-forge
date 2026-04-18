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
class F1215NovaZ32Z2Metadata {
  static const instance = F1215NovaZ32Z2Metadata._();
  const F1215NovaZ32Z2Metadata._();

  String get id => 'f1215_nova_z_3_2_z_2';
  String get name => 'Nova z^3 - 2*z + 2';
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

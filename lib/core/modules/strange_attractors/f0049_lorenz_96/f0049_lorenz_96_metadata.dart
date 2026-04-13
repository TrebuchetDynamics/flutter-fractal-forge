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
class F0049Lorenz96Metadata {
  static const instance = F0049Lorenz96Metadata._();
  const F0049Lorenz96Metadata._();

  String get id => 'f0049_lorenz_96';
  String get name => 'Lorenz-96';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'Lorenz 96',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'E. N. Lorenz',
      title: 'Predictability: a problem partly solved',
      year: 1995,
      url: 'https://www.ecmwf.int/sites/default/files/elibrary/1995/10829-predictability-problem-partly-solved.pdf',
    ),
  ];
}

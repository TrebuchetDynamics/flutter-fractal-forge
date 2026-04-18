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
class F0980ReplicatorB1357S1357Metadata {
  static const instance = F0980ReplicatorB1357S1357Metadata._();
  const F0980ReplicatorB1357S1357Metadata._();

  String get id => 'f0980_replicator_b1357_s1357';
  String get name => 'Replicator (B1357/S1357)';
  String get category => 'Cellular & Stochastic';

  List<String> get aliases => const [
    'Fredkin replicator',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Mirek Wójtowicz',
      title: 'Mirek\'s Cellebration database',
      year: 1999,
      url: 'https://www.mirekw.com/ca/',
    ),
  ];
}

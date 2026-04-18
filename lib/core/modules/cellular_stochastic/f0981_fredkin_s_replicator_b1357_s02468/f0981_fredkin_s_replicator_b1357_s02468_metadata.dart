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
class F0981FredkinSReplicatorB1357S02468Metadata {
  static const instance = F0981FredkinSReplicatorB1357S02468Metadata._();
  const F0981FredkinSReplicatorB1357S02468Metadata._();

  String get id => 'f0981_fredkin_s_replicator_b1357_s02468';
  String get name => 'Fredkin\'s Replicator (B1357/S02468)';
  String get category => 'Cellular & Stochastic';

  List<String> get aliases => const [
    'Fredkin',
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

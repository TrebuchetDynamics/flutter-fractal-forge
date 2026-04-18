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
class F0791RecamNSSequenceMetadata {
  static const instance = F0791RecamNSSequenceMetadata._();
  const F0791RecamNSSequenceMetadata._();

  String get id => 'f0791_recam_n_s_sequence';
  String get name => 'Recamán\'s Sequence';
  String get category => 'Number-Theory Fractals';

  List<String> get aliases => const [
    'Recaman',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'B. Recamán',
      title: 'Sequence A005132',
      year: 1991,
      url: 'https://oeis.org/A005132',
    ),
  ];
}

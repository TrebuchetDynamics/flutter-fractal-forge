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
class F0289ApollonianPackingIfsMetadata {
  static const instance = F0289ApollonianPackingIfsMetadata._();
  const F0289ApollonianPackingIfsMetadata._();

  String get id => 'f0289_apollonian_packing_ifs';
  String get name => 'Apollonian Packing IFS';
  String get category => 'IFS &amp; Geometric Construction';

  List<String> get aliases => const [
    'Apollonian IFS',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'M. F. Barnsley',
      title: 'Fractals Everywhere',
      year: 1988,
      url: 'https://doi.org/10.1016/C2013-0-10335-2',
    ),
  ];
}

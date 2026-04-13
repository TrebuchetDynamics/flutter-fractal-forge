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
class F0280LeafIfsMetadata {
  static const instance = F0280LeafIfsMetadata._();
  const F0280LeafIfsMetadata._();

  String get id => 'f0280_leaf_ifs';
  String get name => 'Leaf IFS';
  String get category => 'IFS &amp; Geometric Construction';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Paul Bourke',
      title: 'Leaf IFS',
      year: 2000,
      url: 'http://paulbourke.net/fractals/ifs/',
    ),
  ];
}

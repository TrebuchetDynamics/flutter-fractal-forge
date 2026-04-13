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
class F0263BarnsleyFernVariantThistleMetadata {
  static const instance = F0263BarnsleyFernVariantThistleMetadata._();
  const F0263BarnsleyFernVariantThistleMetadata._();

  String get id => 'f0263_barnsley_fern_variant_thistle';
  String get name => 'Barnsley Fern (Variant Thistle)';
  String get category => 'IFS &amp; Geometric Construction';

  List<String> get aliases => const [
    'thistle fern',
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

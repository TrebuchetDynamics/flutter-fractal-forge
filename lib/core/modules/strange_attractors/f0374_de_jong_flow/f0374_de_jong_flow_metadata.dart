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
class F0374DeJongFlowMetadata {
  static const instance = F0374DeJongFlowMetadata._();
  const F0374DeJongFlowMetadata._();

  String get id => 'f0374_de_jong_flow';
  String get name => 'de Jong Flow';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    'de Jong a=1.641 b=1.902 c=0.316 d=1.525',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Peter de Jong / Clifford Pickover',
      title: 'Symmetric de Jong attractors',
      year: 1988,
      url: 'http://paulbourke.net/fractals/peterdejong/',
    ),
  ];
}

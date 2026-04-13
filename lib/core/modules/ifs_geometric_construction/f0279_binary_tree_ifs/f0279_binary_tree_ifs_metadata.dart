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
class F0279BinaryTreeIfsMetadata {
  static const instance = F0279BinaryTreeIfsMetadata._();
  const F0279BinaryTreeIfsMetadata._();

  String get id => 'f0279_binary_tree_ifs';
  String get name => 'Binary Tree IFS';
  String get category => 'IFS &amp; Geometric Construction';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Paul Bourke',
      title: 'Binary tree IFS',
      year: 2000,
      url: 'http://paulbourke.net/fractals/ifs/',
    ),
  ];
}

// ignore_for_file: deprecated_member_use
import 'package:flutter/semantics.dart';

/// Depth-first traversal result for a single semantics node.
class NodeReport {
  final int depth;
  final String label;
  final String value;
  final String hint;
  final bool isInteractive;
  final bool hasLabel;
  final List<String> issues;

  const NodeReport({
    required this.depth,
    required this.label,
    required this.value,
    required this.hint,
    required this.isInteractive,
    required this.hasLabel,
    required this.issues,
  });
}

/// Traverses the semantics tree depth-first starting from [node].
///
/// For each node, validates:
///   1. Interactive nodes (tap, longPress, scrollable) must have labels.
///   2. No sibling nodes share the same non-empty label (duplicate detection).
///   3. No label exceeds 100 characters.
///   4. Image nodes (isImage flag) must have a descriptive label.
List<NodeReport> walkSemanticsTree(SemanticsNode node, {int depth = 0}) {
  final reports = <NodeReport>[];
  _walkRecursive(node, depth, reports, <String>{});
  return reports;
}

void _walkRecursive(
  SemanticsNode node,
  int depth,
  List<NodeReport> out,
  Set<String> siblingLabels,
) {
  final data = node.getSemanticsData();
  final label = data.label;
  final value = data.value;
  final hint = data.hint;

  final isInteractive = (data.actions & SemanticsAction.tap.index != 0) ||
      (data.actions & SemanticsAction.longPress.index != 0) ||
      (data.actions & SemanticsAction.scrollUp.index != 0) ||
      (data.actions & SemanticsAction.scrollDown.index != 0) ||
      (data.actions & SemanticsAction.scrollLeft.index != 0) ||
      (data.actions & SemanticsAction.scrollRight.index != 0);

  final isImage = data.flags & SemanticsFlag.isImage.index != 0;

  final hasLabel = label.isNotEmpty;
  final issues = <String>[];

  if (isInteractive && !hasLabel && value.isEmpty) {
    issues.add('Interactive node at depth $depth has no label or value');
  }

  if (label.isNotEmpty && siblingLabels.contains(label)) {
    issues.add('Duplicate sibling label: "$label" at depth $depth');
  }
  if (label.isNotEmpty) {
    siblingLabels.add(label);
  }

  if (label.length > 100) {
    issues.add(
      'Label too long (${label.length} chars) at depth $depth: '
      '"${label.substring(0, 50)}..."',
    );
  }

  if (isImage && !hasLabel) {
    issues.add('Image node at depth $depth has no description');
  }

  out.add(NodeReport(
    depth: depth,
    label: label,
    value: value,
    hint: hint,
    isInteractive: isInteractive,
    hasLabel: hasLabel,
    issues: issues,
  ));

  final childLabels = <String>{};
  node.visitChildren((child) {
    _walkRecursive(child, depth + 1, out, childLabels);
    return true;
  });
}

String formatSemanticsTree(List<NodeReport> nodes) {
  final buf = StringBuffer();
  for (final node in nodes) {
    final indent = '  ' * node.depth;
    buf.writeln('$indent[depth=${node.depth}]');
    if (node.label.isNotEmpty) buf.writeln('$indent  label: "${node.label}"');
    if (node.value.isNotEmpty) buf.writeln('$indent  value: "${node.value}"');
    if (node.hint.isNotEmpty) buf.writeln('$indent  hint: "${node.hint}"');
    buf.writeln('$indent  interactive: ${node.isInteractive}');
    if (node.issues.isNotEmpty) {
      for (final issue in node.issues) {
        buf.writeln('$indent  ISSUE: $issue');
      }
    }
  }
  return buf.toString();
}

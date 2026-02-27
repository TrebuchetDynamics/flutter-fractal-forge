import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

/// Depth-first traversal of a [SemanticsNode] tree.
///
/// Visits every node and collects a [SemanticsNodeInfo] for each one that
/// carries meaningful semantic data (label, value, hint, or actions).
///
/// Returns the list in depth-first order.
List<SemanticsNodeInfo> traverseSemanticsTree(SemanticsNode root) {
  final result = <SemanticsNodeInfo>[];
  _visit(root, 0, result);
  return result;
}

void _visit(SemanticsNode node, int depth, List<SemanticsNodeInfo> out) {
  final data = node.getSemanticsData();
  final label = data.label;
  final value = data.value;
  final hint = data.hint;
  final actions = <String>[];

  for (final action in SemanticsAction.values) {
    if (data.actions & action.index != 0) {
      actions.add(_actionName(action));
    }
  }

  final flags = <String>[];
  // ignore: deprecated_member_use
  for (final flag in SemanticsFlag.values) {
    // ignore: deprecated_member_use
    if (data.flags & flag.index != 0) {
      flags.add(_flagName(flag));
    }
  }

  // Only record nodes that carry meaningful semantic information.
  if (label.isNotEmpty ||
      value.isNotEmpty ||
      hint.isNotEmpty ||
      actions.isNotEmpty ||
      flags.isNotEmpty) {
    out.add(SemanticsNodeInfo(
      depth: depth,
      label: label,
      value: value,
      hint: hint,
      actions: actions,
      flags: flags,
    ));
  }

  node.visitChildren((child) {
    _visit(child, depth + 1, out);
    return true;
  });
}

/// Produces a human-readable narrative string from a list of
/// [SemanticsNodeInfo] entries.
///
/// Each node is indented by its depth and shows label, value, hint,
/// actions, and flags on separate indented lines.
String buildSemanticsNarrative(List<SemanticsNodeInfo> nodes) {
  final buffer = StringBuffer();
  for (final node in nodes) {
    final indent = '  ' * node.depth;
    buffer.writeln('$indent[depth=${node.depth}]');
    if (node.label.isNotEmpty) {
      buffer.writeln('$indent  label: "${node.label}"');
    }
    if (node.value.isNotEmpty) {
      buffer.writeln('$indent  value: "${node.value}"');
    }
    if (node.hint.isNotEmpty) {
      buffer.writeln('$indent  hint: "${node.hint}"');
    }
    if (node.actions.isNotEmpty) {
      buffer.writeln('$indent  actions: [${node.actions.join(', ')}]');
    }
    if (node.flags.isNotEmpty) {
      buffer.writeln('$indent  flags: [${node.flags.join(', ')}]');
    }
  }
  return buffer.toString();
}

/// Compares a [narrative] against a [baseline] string.
///
/// Returns a [SemanticsComparisonResult] that reports whether they match
/// and, if not, provides a human-readable diff summary.
SemanticsComparisonResult compareSemanticsNarrative(
  String narrative,
  String baseline,
) {
  if (narrative.trim() == baseline.trim()) {
    return const SemanticsComparisonResult(matches: true, diff: '');
  }

  final narrativeLines = narrative.trimRight().split('\n');
  final baselineLines = baseline.trimRight().split('\n');

  final buffer = StringBuffer();
  final maxLen = narrativeLines.length > baselineLines.length
      ? narrativeLines.length
      : baselineLines.length;

  for (var i = 0; i < maxLen; i++) {
    final actual = i < narrativeLines.length ? narrativeLines[i] : '<missing>';
    final expected = i < baselineLines.length ? baselineLines[i] : '<missing>';
    if (actual != expected) {
      buffer.writeln('Line ${i + 1}:');
      buffer.writeln('  expected: $expected');
      buffer.writeln('  actual:   $actual');
    }
  }

  return SemanticsComparisonResult(matches: false, diff: buffer.toString());
}

/// Extracts the full semantics tree narrative from a pumped [WidgetTester].
///
/// Requires semantics to be enabled via [tester.binding.ensureSemantics()]
/// before calling.
String extractSemanticsNarrative(WidgetTester tester) {
  // Access the semantics owner via the root pipeline owner.
  // ignore: deprecated_member_use
  final root = tester.binding.pipelineOwner.semanticsOwner?.rootSemanticsNode;
  if (root == null) {
    return '<semantics not enabled or no root>';
  }
  final nodes = traverseSemanticsTree(root);
  return buildSemanticsNarrative(nodes);
}

/// Information extracted from a single [SemanticsNode].
class SemanticsNodeInfo {
  final int depth;
  final String label;
  final String value;
  final String hint;
  final List<String> actions;
  final List<String> flags;

  const SemanticsNodeInfo({
    required this.depth,
    required this.label,
    required this.value,
    required this.hint,
    required this.actions,
    required this.flags,
  });

  @override
  String toString() =>
      'SemanticsNodeInfo(depth=$depth, label="$label", value="$value", '
      'hint="$hint", actions=$actions, flags=$flags)';
}

/// Result of comparing a semantics narrative against a baseline.
class SemanticsComparisonResult {
  final bool matches;
  final String diff;

  const SemanticsComparisonResult({
    required this.matches,
    required this.diff,
  });
}

// ---------------------------------------------------------------------------
// Private helpers
// ---------------------------------------------------------------------------

String _actionName(SemanticsAction action) {
  // Use known constant identities for readable names.
  if (action == SemanticsAction.tap) return 'tap';
  if (action == SemanticsAction.longPress) return 'longPress';
  if (action == SemanticsAction.scrollLeft) return 'scrollLeft';
  if (action == SemanticsAction.scrollRight) return 'scrollRight';
  if (action == SemanticsAction.scrollUp) return 'scrollUp';
  if (action == SemanticsAction.scrollDown) return 'scrollDown';
  if (action == SemanticsAction.increase) return 'increase';
  if (action == SemanticsAction.decrease) return 'decrease';
  if (action == SemanticsAction.copy) return 'copy';
  if (action == SemanticsAction.cut) return 'cut';
  if (action == SemanticsAction.paste) return 'paste';
  if (action == SemanticsAction.moveCursorForwardByCharacter) {
    return 'moveCursorForwardByCharacter';
  }
  if (action == SemanticsAction.moveCursorBackwardByCharacter) {
    return 'moveCursorBackwardByCharacter';
  }
  if (action == SemanticsAction.dismiss) return 'dismiss';
  if (action == SemanticsAction.setText) return 'setText';
  if (action == SemanticsAction.focus) return 'focus';
  return 'action(${action.index})';
}

String _flagName(SemanticsFlag flag) {
  if (flag == SemanticsFlag.hasCheckedState) return 'hasCheckedState';
  if (flag == SemanticsFlag.isChecked) return 'isChecked';
  if (flag == SemanticsFlag.isSelected) return 'isSelected';
  if (flag == SemanticsFlag.isButton) return 'isButton';
  if (flag == SemanticsFlag.isTextField) return 'isTextField';
  if (flag == SemanticsFlag.isFocusable) return 'isFocusable';
  if (flag == SemanticsFlag.isFocused) return 'isFocused';
  if (flag == SemanticsFlag.hasEnabledState) return 'hasEnabledState';
  if (flag == SemanticsFlag.isEnabled) return 'isEnabled';
  if (flag == SemanticsFlag.isInMutuallyExclusiveGroup) {
    return 'isInMutuallyExclusiveGroup';
  }
  if (flag == SemanticsFlag.isHeader) return 'isHeader';
  if (flag == SemanticsFlag.isObscured) return 'isObscured';
  if (flag == SemanticsFlag.isSlider) return 'isSlider';
  if (flag == SemanticsFlag.isImage) return 'isImage';
  if (flag == SemanticsFlag.isLiveRegion) return 'isLiveRegion';
  if (flag == SemanticsFlag.hasToggledState) return 'hasToggledState';
  if (flag == SemanticsFlag.isToggled) return 'isToggled';
  if (flag == SemanticsFlag.hasImplicitScrolling) return 'hasImplicitScrolling';
  if (flag == SemanticsFlag.isLink) return 'isLink';
  if (flag == SemanticsFlag.isReadOnly) return 'isReadOnly';
  if (flag == SemanticsFlag.isKeyboardKey) return 'isKeyboardKey';
  if (flag == SemanticsFlag.scopesRoute) return 'scopesRoute';
  if (flag == SemanticsFlag.namesRoute) return 'namesRoute';
  if (flag == SemanticsFlag.isHidden) return 'isHidden';
  return 'flag(${flag.index})';
}

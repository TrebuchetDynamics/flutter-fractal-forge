import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

/// One interactive semantics node the platform surfaces without a name.
class UnnamedControl {
  final Rect rect;
  final int actions;
  final String value;

  const UnnamedControl({
    required this.rect,
    required this.actions,
    required this.value,
  });

  @override
  String toString() => 'unnamed control at $rect '
      '(actions=$actions${value.isEmpty ? '' : ', value="$value"'})';
}

/// Actions that make a node something the user operates, as opposed to a
/// container they merely scroll.
///
/// Scroll actions are excluded on purpose: a `ListView`/`GridView` produces a
/// scrollable node with no name of its own, which is correct and appears in
/// every Flutter app.
const int _operableActions = 0 |
    1 << 0 | // tap
    1 << 1 | // longPress
    1 << 6 | // increase
    1 << 7; // decrease

/// Finds controls a screen reader would announce with no name.
///
/// This catches the "split semantics" shape that a `Semantics(label: ...)`
/// wrapper produces when something between it and the gesture widget forces a
/// semantics boundary (a `Tooltip`, a `FocusableActionDetector`, a `Slider`'s
/// own thumb node): the name lands on one node and the action on another, so
/// the operable node is anonymous.
///
/// Deliberately narrower than [walkSemanticsTree]'s issue list, which reports
/// two shapes that are not defects:
///   * nodes merged into an ancestor — the platform never surfaces them
///     separately, so an empty label there is expected;
///   * a bare `IconButton(tooltip: ...)`, whose name reaches screen readers
///     through the tooltip rather than the label.
List<UnnamedControl> findUnnamedControls(SemanticsNode root) {
  final found = <UnnamedControl>[];

  void walk(SemanticsNode node) {
    if (!node.isMergedIntoParent) {
      final data = node.getSemanticsData();
      final operable = data.actions & _operableActions != 0;
      final named = data.label.trim().isNotEmpty ||
          data.tooltip.trim().isNotEmpty ||
          data.value.trim().isNotEmpty;
      if (operable && !named) {
        found.add(UnnamedControl(
          rect: node.rect,
          actions: data.actions,
          value: data.value,
        ));
      }
    }
    node.visitChildren((child) {
      walk(child);
      return true;
    });
  }

  walk(root);
  return found;
}

/// Operable nodes that sit inside another operable node.
///
/// This is the structural signature of the "split semantics" shape, and it does
/// not depend on guessing whether a node is adequately named: one control has
/// produced two stops, so a screen reader user swipes twice through it and the
/// tap and long-press actions land on different announcements.
///
/// A `Semantics(label:) > Tooltip > GestureDetector` chain yields an outer node
/// with the label and long-press and an inner node with the tap, the inner one
/// named only by the tooltip. Wrapping in `MergeSemantics` collapses them.
List<String> findStackedStops(SemanticsNode root) {
  final stacked = <String>[];

  void walk(SemanticsNode node, {required Rect? operableAncestor}) {
    var ancestor = operableAncestor;
    if (!node.isMergedIntoParent) {
      final data = node.getSemanticsData();
      if (data.actions & _operableActions != 0) {
        // Only a pair covering the same area is one control split in two. A
        // small control nested inside a large operable surface — a FAB over a
        // pan/zoom canvas — is ordinary layering, not a split.
        if (ancestor != null && _isSameControl(ancestor, node.rect)) {
          final name = data.label.trim().isNotEmpty
              ? data.label.trim()
              : data.tooltip.trim();
          stacked.add(name.isEmpty ? '<unnamed> at ${node.rect}' : name);
        }
        ancestor = node.rect;
      }
    }
    node.visitChildren((child) {
      walk(child, operableAncestor: ancestor);
      return true;
    });
  }

  walk(root, operableAncestor: null);
  return stacked;
}

/// Whether two operable rects are close enough in size to be the same control.
bool _isSameControl(Rect outer, Rect inner) {
  final outerArea = outer.width * outer.height;
  final innerArea = inner.width * inner.height;
  if (outerArea <= 0) return false;
  return innerArea / outerArea > 0.8;
}

/// Sliders that announce a value but never say what they adjust.
///
/// A value alone is not a name: "69%" tells a screen reader user nothing about
/// which parameter moved. Checked separately from [findUnnamedControls], which
/// accepts a value as sufficient for ordinary controls.
List<String> findUnnamedSliders(SemanticsNode root) {
  final bare = <String>[];

  void walk(SemanticsNode node) {
    if (!node.isMergedIntoParent) {
      final data = node.getSemanticsData();
      if (data.flagsCollection.isSlider &&
          data.label.trim().isEmpty &&
          data.tooltip.trim().isEmpty) {
        bare.add('slider value="${data.value}" at ${node.rect}');
      }
    }
    node.visitChildren((child) {
      walk(child);
      return true;
    });
  }

  walk(root);
  return bare;
}

/// Every operable node the platform surfaces, by name. Useful for asserting a
/// screen exposes the controls it should, and for spotting duplicates.
List<String> operableControlNames(SemanticsNode root) {
  final names = <String>[];

  void walk(SemanticsNode node) {
    if (!node.isMergedIntoParent) {
      final data = node.getSemanticsData();
      if (data.actions & _operableActions != 0) {
        final name = data.label.trim().isNotEmpty
            ? data.label.trim()
            : data.tooltip.trim();
        if (name.isNotEmpty) names.add(name);
      }
    }
    node.visitChildren((child) {
      walk(child);
      return true;
    });
  }

  walk(root);
  return names;
}

/// The semantics root for the tree under test.
///
/// `rootPipelineOwner.semanticsOwner` is null in a widget test, so the
/// deprecated accessor is the working one here.
SemanticsNode semanticsRoot(WidgetTester tester) {
  // ignore: deprecated_member_use
  final owner = tester.binding.pipelineOwner.semanticsOwner;
  expect(owner, isNotNull, reason: 'call tester.ensureSemantics() first');
  final root = owner!.rootSemanticsNode;
  expect(root, isNotNull, reason: 'semantics tree has no root');
  return root!;
}

/// Guard against [SemanticsAction] bit values drifting out from under
/// [_operableActions].
void assertActionBitsUnchanged() {
  expect(SemanticsAction.tap.index, 1 << 0);
  expect(SemanticsAction.longPress.index, 1 << 1);
  expect(SemanticsAction.increase.index, 1 << 6);
  expect(SemanticsAction.decrease.index, 1 << 7);
}

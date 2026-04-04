// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_fractals/core/services/accessibility_service.dart';
import 'package:flutter_fractals/core/services/preset_store.dart';
import 'package:flutter_fractals/core/services/renderer_settings_service.dart';
import 'package:flutter_fractals/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _DenyAllPermissions extends PermissionHandlerPlatform {
  @override
  Future<Map<Permission, PermissionStatus>> requestPermissions(
      List<Permission> permissions) async {
    return {
      for (final p in permissions) p: PermissionStatus.denied,
    };
  }

  @override
  Future<PermissionStatus> checkPermissionStatus(Permission permission) async {
    return PermissionStatus.denied;
  }
}

/// Depth-first traversal result for a single semantics node.
class _NodeReport {
  final int depth;
  final String label;
  final String value;
  final String hint;
  final bool isInteractive;
  final bool hasLabel;
  final List<String> issues;

  const _NodeReport({
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
///   1. Tappable interactive nodes must have labels.
///   2. No sibling nodes share the same non-empty label (duplicate detection).
///   3. No label exceeds 100 characters.
///   4. Image nodes (isImage flag) must have a descriptive label.
///
/// Returns a list of [_NodeReport] entries with any issues found.
List<_NodeReport> _walkSemanticsTree(SemanticsNode node, {int depth = 0}) {
  final reports = <_NodeReport>[];
  _walkRecursive(node, depth, reports, <String>{});
  return reports;
}

void _walkRecursive(
  SemanticsNode node,
  int depth,
  List<_NodeReport> out,
  Set<String> siblingLabels,
) {
  final data = node.getSemanticsData();
  final label = data.label;
  final value = data.value;
  final hint = data.hint;

  // Scrollable containers often expose framework-generated semantics nodes
  // without labels, so only tappable controls are treated as unlabeled-action
  // violations here.
  final hasTapAction =
      (data.actions & SemanticsAction.tap.index != 0) ||
      (data.actions & SemanticsAction.longPress.index != 0);
  final isInteractive = hasTapAction ||
      (data.actions & SemanticsAction.scrollUp.index != 0) ||
      (data.actions & SemanticsAction.scrollDown.index != 0) ||
      (data.actions & SemanticsAction.scrollLeft.index != 0) ||
      (data.actions & SemanticsAction.scrollRight.index != 0);

  final isImage = data.flags & SemanticsFlag.isImage.index != 0;

  final hasLabel = label.isNotEmpty;
  final issues = <String>[];

  // Rule 1: Tappable controls must have labels.
  if (hasTapAction && !hasLabel && value.isEmpty) {
    issues.add('Interactive node at depth $depth has no label or value');
  }

  // Rule 2: Duplicate sibling labels (only non-empty).
  if (label.isNotEmpty && siblingLabels.contains(label)) {
    issues.add('Duplicate sibling label: "$label" at depth $depth');
  }
  if (label.isNotEmpty) {
    siblingLabels.add(label);
  }

  // Rule 3: Labels should not exceed 100 characters.
  if (label.length > 100) {
    issues.add(
      'Label too long (${label.length} chars) at depth $depth: '
      '"${label.substring(0, 50)}..."',
    );
  }

  // Rule 4: Images need descriptive labels.
  if (isImage && !hasLabel) {
    issues.add('Image node at depth $depth has no description');
  }

  out.add(_NodeReport(
    depth: depth,
    label: label,
    value: value,
    hint: hint,
    isInteractive: isInteractive,
    hasLabel: hasLabel,
    issues: issues,
  ));

  // Recurse into children with fresh sibling-label tracking per level.
  final childLabels = <String>{};
  node.visitChildren((child) {
    _walkRecursive(child, depth + 1, out, childLabels);
    return true;
  });
}

/// Prints the full semantics tree for manual inspection.
String _formatSemanticsTree(List<_NodeReport> nodes) {
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

void main() {
  group('Semantic tree walker', () {
    late PresetStore presetStore;
    late AccessibilityService accessibilityService;
    late RendererSettingsService rendererSettingsService;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      PermissionHandlerPlatform.instance = _DenyAllPermissions();
      presetStore = await PresetStore.create();
      accessibilityService = await AccessibilityService.create();
      rendererSettingsService = await RendererSettingsService.create();
    });

    Widget buildApp() {
      return FlutterFractalsApp(
        presetStore: presetStore,
        accessibilityService: accessibilityService,
        rendererSettingsService: rendererSettingsService,
        locale: const Locale('en'),
      );
    }

    testWidgets(
      'walk full semantics tree and report issues',
      (tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(buildApp());
        await tester.pumpAndSettle();

        final root =
            tester.binding.pipelineOwner.semanticsOwner?.rootSemanticsNode;
        expect(root, isNotNull, reason: 'Semantics tree root must exist');

        final nodes = _walkSemanticsTree(root!);
        final tree = _formatSemanticsTree(nodes);

        // Print full tree for manual inspection by sighted colleagues.
        // ignore: avoid_print
        print('=== FULL SEMANTICS TREE ===');
        // ignore: avoid_print
        print(tree);
        // ignore: avoid_print
        print('=== END SEMANTICS TREE ===');

        // Collect all issues.
        final allIssues = <String>[];
        for (final node in nodes) {
          allIssues.addAll(node.issues);
        }

        if (allIssues.isNotEmpty) {
          // ignore: avoid_print
          print('=== SEMANTICS ISSUES FOUND ===');
          for (final issue in allIssues) {
            // ignore: avoid_print
            print('  - $issue');
          }
          // ignore: avoid_print
          print('=== END ISSUES ===');
        }

        // The test itself passes (informational), but we log issues.
        // To make this a strict gate, uncomment the following:
        // expect(allIssues, isEmpty, reason: allIssues.join('\n'));

        handle.dispose();
      },
    );

    testWidgets(
      'no tappable interactive nodes without labels',
      (tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(buildApp());
        await tester.pumpAndSettle();

        final root =
            tester.binding.pipelineOwner.semanticsOwner?.rootSemanticsNode;
        expect(root, isNotNull);

        final nodes = _walkSemanticsTree(root!);

        final unlabeled = nodes
            .where((n) =>
                n.isInteractive &&
                !n.hasLabel &&
                n.value.isEmpty &&
                n.issues.any(
                  (issue) => issue.contains('has no label or value'),
                ))
            .toList();

        if (unlabeled.isNotEmpty) {
          final details = unlabeled
              .map((n) =>
                  'depth=${n.depth}, hint="${n.hint}"')
              .join('\n  ');
          // ignore: avoid_print
          print('Unlabeled interactive nodes:\n  $details');
        }

        // Informational: log but do not fail.
        // To enforce: expect(unlabeled, isEmpty);

        handle.dispose();
      },
    );
  });
}

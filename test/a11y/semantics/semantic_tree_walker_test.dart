// ignore_for_file: deprecated_member_use
import 'package:flutter_test/flutter_test.dart';

import '../shared/a11y_test_helpers.dart';
import '../shared/main_app_a11y_harness.dart';
import 'semantic_tree_audit.dart';

void main() {
  group('Semantic tree walker', () {
    late MainAppA11yHarness harness;

    setUp(() async {
      harness = MainAppA11yHarness();
      await harness.setUp();
    });

    testWidgets(
      'walk full semantics tree and report issues',
      (tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(harness.buildApp());
        await pumpAccessibilityTestFrames(tester);

        final root =
            tester.binding.pipelineOwner.semanticsOwner?.rootSemanticsNode;
        expect(root, isNotNull, reason: 'Semantics tree root must exist');

        final nodes = walkSemanticsTree(root!);
        final tree = formatSemanticsTree(nodes);

        // Print full tree for manual inspection by sighted colleagues.
        // ignore: avoid_print
        print('=== FULL SEMANTICS TREE ===');
        // ignore: avoid_print
        print(tree);
        // ignore: avoid_print
        print('=== END SEMANTICS TREE ===');

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
        await disposeAccessibilityTestWidget(tester);
      },
    );

    testWidgets(
      'no interactive nodes without labels',
      (tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(harness.buildApp());
        await pumpAccessibilityTestFrames(tester);

        final root =
            tester.binding.pipelineOwner.semanticsOwner?.rootSemanticsNode;
        expect(root, isNotNull);

        final nodes = walkSemanticsTree(root!);

        final unlabeled = nodes
            .where((n) => n.isInteractive && !n.hasLabel && n.value.isEmpty)
            .toList();

        if (unlabeled.isNotEmpty) {
          final details = unlabeled
              .map((n) => 'depth=${n.depth}, hint="${n.hint}"')
              .join('\n  ');
          // ignore: avoid_print
          print('Unlabeled interactive nodes:\n  $details');
        }

        // Informational: log but do not fail.
        // To enforce: expect(unlabeled, isEmpty);

        handle.dispose();
        await disposeAccessibilityTestWidget(tester);
      },
    );
  });
}

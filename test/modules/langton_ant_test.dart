import 'package:flutter_fractals/core/modules/fractals/langton_ant_frame.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('classic first turns, with positive Y pointing up', () {
    final frames =
        List.generate(5, (steps) => LangtonAntFrame.simulate('RL', steps));
    expect(frames.map((f) => (f.x, f.y)),
        [(0, 0), (1, 0), (1, -1), (0, -1), (0, 0)]);
    expect(frames[0].cells, isEmpty);
    expect(frames[3].colorAt(0, 0), 1);
    expect(frames[3].colorAt(1, 0), 1);
    expect(frames[3].colorAt(1, -1), 1);
  });

  test('classic highway translates by (-2,-2) per 104 steps', () {
    for (final t in [10500, 10604, 10708]) {
      final a = LangtonAntFrame.simulate('RL', t);
      final b = LangtonAntFrame.simulate('RL', t + 104);
      expect((b.x - a.x, b.y - a.y), (-2, -2));
    }
  });

  test('multicolor runs are deterministic and all presets leave a grid', () {
    for (final rule in langtonAntRules) {
      final frame = LangtonAntFrame.simulate(rule, 11000);
      expect(frame.completedSteps, 11000);
      expect(frame.cells, isNotEmpty, reason: rule);
      expect(frame.cells, LangtonAntFrame.simulate(rule, 11000).cells);
    }
    expect(LangtonAntFrame.simulate('RLR', 5).colorAt(0, 0), 2);
  });

  test('a move outside the box does not partly apply a step', () {
    final frame = LangtonAntFrame.simulate('LL', 1, bound: 0);
    expect(frame.completedSteps, 0);
    expect((frame.x, frame.y), (0, 0));
    expect(frame.cells, isEmpty);
  });

  test('rules are normalized without discarding invalid characters', () {
    expect(normalizeLangtonAntRule('rllr'), 'RLLR');
    expect(normalizeLangtonAntRule('L' * 20), 'L' * 20);
    for (final value in ['', 'L', 'RLX', 'R L', 'RL\n', 'R' * 21]) {
      expect(normalizeLangtonAntRule(value), isNull, reason: value);
    }
  });

  test('million-step native worker returns in under two seconds', () async {
    final elapsed = Stopwatch()..start();
    final frame = await LangtonAntFrame.prepare('LRRRRRLLR', 1000000);
    expect(frame.completedSteps, 1000000);
    expect(elapsed.elapsed, lessThan(const Duration(seconds: 2)));
  });
}

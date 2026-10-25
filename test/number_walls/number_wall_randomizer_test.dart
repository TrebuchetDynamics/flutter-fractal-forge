import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/models/number_wall_model.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('seeded manual randomization materializes, replays and undoes settings',
      () async {
    final controller = FractalController(ModuleRegistry());
    addTearDown(controller.dispose);
    final module = controller.registry.byId('number_wall');
    await controller.loadState(
        module: module,
        params: {
          ...module.defaultPreset.params,
          'prime': '97',
          'rows': 4,
          'columns': 16,
        },
        view: module.defaultPreset.view);
    expect(
        await controller.applyNumberWallPrime('1000000000039',
            maxTrialDivisions: 600000),
        NumberWallPrimeStatus.verifiedPrime);
    final before = Map<String, Object>.from(controller.params);
    final grid = controller.numberWallGrid;
    expect(await controller.randomizeNumberWall(seed: 42), isTrue);
    final randomized = Map<String, Object>.from(controller.params);
    expect(randomized['prime'], '1000000000039');
    expect(randomized['randomSeed'], 42);
    for (final id in ['rows', 'columns', 'columnStart']) {
      expect(randomized[id], before[id]);
    }
    expect(controller.undoNumberWallRandomization(), isTrue);
    expect(controller.params, before);
    expect(controller.numberWallGrid, same(grid));
    await controller.randomizeNumberWall(seed: 42);
    expect(controller.params, randomized);
    expect(
        await controller.loadState(params: randomized, view: controller.view),
        isTrue);
    expect(controller.params, randomized);
    controller.updateParam('randomizeModulus', true);
    await Future<void>.delayed(Duration.zero);
    for (var seed = 0; seed < 6; seed++) {
      await controller.randomizeNumberWall(seed: seed);
      final prime = controller.params['prime'] as String;
      expect(['2', '3', '5', '7', '11', '13'], contains(prime));
      expect((await NumberWallPrimeValidator.validate(prime)).status,
          NumberWallPrimeStatus.verifiedPrime);
    }
  });
}

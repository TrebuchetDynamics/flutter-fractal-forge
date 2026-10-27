import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/features/renderer/cpu/cpu_render_isolate.dart';
import 'package:flutter_fractals/features/renderer/policy/precision_ladder_policy.dart';

void main() {
  test('nonquadratic Burning Ship avoids quadratic perturbation', () {
    const policy = PrecisionLadderPolicy();
    for (final power in [1.5, 2.5, 3.0, 7.0, 12.0]) {
      expect(
          policy
              .decide(
                  moduleId: 'burning_ship',
                  dimension: FractalDimension.twoD,
                  zoom: 1e10,
                  power: power)
              .renderPath,
          PrecisionLadderRenderPath.cpu);
    }
    expect(
        policy
            .decide(
                moduleId: 'burning_ship',
                dimension: FractalDimension.twoD,
                zoom: 1e7,
                power: 2)
            .renderPath,
        PrecisionLadderRenderPath.gpuPerturbation);
  });

  test('CPU frame and tiles honor the Burning Ship power', () {
    // Independently sampled c=(-0.8,-0.6): degree 2 remains bounded for 40
    // steps; degrees 2.5,3,4,7 escape before step 30 at radius 4.
    List<int> sample(double power, {bool tile = false}) {
      if (tile) {
        return renderCpuTileInIsolate(CpuTileRenderRequest(
          moduleId: 'burning_ship',
          panX: -0.8,
          panY: 0.6,
          zoom: 1,
          iterations: 40,
          bailout: 4,
          juliaCX: 0,
          juliaCY: 0,
          fullWidth: 1,
          fullHeight: 1,
          x0: 0,
          y0: 0,
          w: 1,
          h: 1,
          sampleCount: 1,
          power: power,
        )).rgba;
      }
      return renderCpuFrameInIsolate(CpuRenderRequest(
        moduleId: 'burning_ship',
        panX: -0.8,
        panY: 0.6,
        zoom: 1,
        iterations: 40,
        bailout: 4,
        juliaCX: 0,
        juliaCY: 0,
        width: 1,
        height: 1,
        sampleCount: 1,
        power: power,
      )).rgba;
    }

    expect(sample(2), [46, 120, 220, 255]);
    for (final power in [3.0, 4.0, 7.0]) {
      expect(sample(power), isNot([46, 120, 220, 255]));
      expect(sample(power, tile: true), sample(power));
    }
    expect(sample(2.5), isNot(sample(2)));
  });
}

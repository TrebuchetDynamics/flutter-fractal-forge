import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';

/// Control surfaces render `FractalParameter.resolvedControl`, so the schema
/// must stay the only place that decides which widget a parameter gets.
void main() {
  group('FractalParameter.resolvedControl', () {
    FractalParameter param(FractalParamType type, {FractalParamControl? control}) {
      return FractalParameter(
        id: 'p',
        label: (_) => 'p',
        type: type,
        min: 0,
        max: 1,
        step: 1,
        defaultValue: switch (type) {
          FractalParamType.float => 0.0,
          FractalParamType.integer => 0,
          FractalParamType.enumeration => 0,
          FractalParamType.decimalInteger => '0',
          FractalParamType.boolean => false,
        },
        control: control,
      );
    }

    test('derives the control from the type when none is declared', () {
      expect(param(FractalParamType.float).resolvedControl,
          FractalParamControl.slider);
      expect(param(FractalParamType.integer).resolvedControl,
          FractalParamControl.slider);
      expect(param(FractalParamType.enumeration).resolvedControl,
          FractalParamControl.chips);
      expect(param(FractalParamType.boolean).resolvedControl,
          FractalParamControl.toggle);
      expect(param(FractalParamType.decimalInteger).resolvedControl,
          FractalParamControl.prime);
    });

    test('a declared control wins over the type default', () {
      expect(
        param(FractalParamType.integer, control: FractalParamControl.color)
            .resolvedControl,
        FractalParamControl.color,
      );
    });
  });

  group('module declarations stay compatible with their values', () {
    final registry = ModuleRegistry();

    test('each declared control matches the stored value type', () {
      for (final module in registry.modules) {
        for (final parameter in module.parameters) {
          final reason = '${module.id}.${parameter.id} '
              '(${parameter.type.name} -> ${parameter.resolvedControl.name})';
          switch (parameter.resolvedControl) {
            case FractalParamControl.slider:
              expect(
                parameter.type,
                anyOf(FractalParamType.float, FractalParamType.integer),
                reason: reason,
              );
            case FractalParamControl.chips:
              expect(parameter.type, FractalParamType.enumeration,
                  reason: reason);
            case FractalParamControl.toggle:
              expect(parameter.type, FractalParamType.boolean, reason: reason);
            case FractalParamControl.prime:
              expect(parameter.type, FractalParamType.decimalInteger,
                  reason: reason);
            case FractalParamControl.color:
              expect(parameter.type, FractalParamType.integer, reason: reason);
          }
        }
      }
    });

    test('number walls declare their colours and prime editor', () {
      final wall = registry.byId('number_wall');
      final controls = {
        for (final parameter in wall.parameters)
          parameter.id: parameter.resolvedControl,
      };
      for (final id in const ['foregroundColor', 'zeroColor', 'backgroundColor']) {
        expect(controls[id], FractalParamControl.color, reason: id);
      }
      expect(controls['prime'], FractalParamControl.prime);
    });

    test('no other module claims the colour swatch', () {
      final colourOwners = {
        for (final module in registry.modules)
          for (final parameter in module.parameters)
            if (parameter.resolvedControl == FractalParamControl.color)
              module.id,
      };
      expect(colourOwners, {'number_wall'});
    });

    test('only number walls hide the shared effect controls', () {
      final hiding = {
        for (final module in registry.modules)
          if (module.hidesEffectControls) module.id,
      };
      expect(hiding, {'number_wall'},
          reason: 'a second exception needs its own review, not a silent add');
    });
  });
}

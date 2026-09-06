import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/models/fractal_preset.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import '../../integration_test/catalog/linux_fractal_audit.dart' as audit;

void main() {
  test('renamed Classic aliases cannot masquerade as a second view', () {
    final module = ModuleRegistry().byId('multibrot5');
    final base = module.defaultPreset;
    final alias =
        module.builtInPresets.firstWhere((p) => p.id.endsWith('-classic'));
    expect(alias.id, isNot(base.id));
    expect(audit.isDistinctAuditPreset(base, alias), isFalse);
    final different = FractalPreset(
        id: 'different',
        moduleId: module.id,
        name: 'Different view',
        createdAt: base.createdAt,
        params: base.params,
        view: base.view.copyWith(zoom: base.view.zoom * .75));
    expect(audit.isDistinctAuditPreset(base, different), isTrue);
    final relief =
        module.builtInPresets.firstWhere((p) => p.id.contains('relief'));
    expect(audit.isDistinctAuditPreset(base, relief), isTrue);
  });
}

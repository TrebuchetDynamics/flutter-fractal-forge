import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/renderer/widgets/renderer/fractal_renderer.dart';
import 'package:provider/provider.dart';

void main() {
  final registry = ModuleRegistry();
  final controller = FractalController(registry);
  runApp(
    ChangeNotifierProvider.value(
      value: controller,
      child: const MaterialApp(home: _RendererSwitchFixture()),
    ),
  );
}

class _RendererSwitchFixture extends StatefulWidget {
  const _RendererSwitchFixture();

  @override
  State<_RendererSwitchFixture> createState() => _RendererSwitchFixtureState();
}

class _RendererSwitchFixtureState extends State<_RendererSwitchFixture> {
  @override
  void initState() {
    super.initState();
    _runSwitches();
  }

  Future<void> _runSwitches() async {
    final controller = context.read<FractalController>();
    final registry = controller.registry;
    await Future<void>.delayed(const Duration(seconds: 3));
    for (final id in ['mandelbulb', 'mandelbrot', 'mandelbulb']) {
      controller.selectModule(registry.byId(id), animate: false);
      debugPrint('RENDERER_SWITCH_FIXTURE_SELECTED:$id');
      await Future<void>.delayed(const Duration(seconds: 3));
    }
  }

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: SizedBox.expand(child: FractalRenderer()),
      );
}

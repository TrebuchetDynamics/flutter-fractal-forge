import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class FractalControllerWidgetHarness {
  FractalControllerWidgetHarness() : registry = ModuleRegistry() {
    // ponytail: replace with injectable registry only if tests need custom modules.
    controller = FractalController(registry);
  }

  final ModuleRegistry registry;
  late final FractalController controller;

  Widget wrap(
    Widget child, {
    Locale locale = const Locale('en'),
    ThemeData? theme,
  }) {
    return ChangeNotifierProvider.value(
      value: controller,
      child: MaterialApp(
        theme: theme,
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    );
  }

  Widget wrapScaffold(
    Widget body, {
    Locale locale = const Locale('en'),
    ThemeData? theme,
  }) =>
      wrap(Scaffold(body: body), locale: locale, theme: theme);

  Widget textFromController(String Function(FractalController ctrl) text) {
    return wrap(
      Consumer<FractalController>(
        builder: (context, ctrl, child) => Text(text(ctrl)),
      ),
    );
  }

  void dispose() => controller.dispose();
}

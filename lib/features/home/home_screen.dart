import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/catalog/fractal_catalog_screen.dart';
import 'package:flutter_fractals/features/ar/ar_overlay_screen.dart';
import 'package:flutter_fractals/features/renderer/providers/fractal_provider.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  late final FractalController _exploreController;
  late final FractalController _arController;

  @override
  void initState() {
    super.initState();
    final registry = context.read<ModuleRegistry>();
    // Keep controller state scoped per tab so AR-specific tweaks (quality presets,
    // transparent background) don't leak into the Explore/catalog/viewer flow.
    _exploreController = FractalController(registry);
    _arController = FractalController(registry);
  }

  @override
  void dispose() {
    _exploreController.dispose();
    _arController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final body = _index == 0
        ? ChangeNotifierProvider.value(
            value: _exploreController,
            child: const FractalCatalogScreen(),
          )
        : ChangeNotifierProvider.value(
            value: _arController,
            child: const ArOverlayScreen(),
          );

    return Scaffold(
      appBar: AppBar(
        title: Text(_index == 0 ? l10n.catalogTitle : l10n.arTitle),
      ),
      body: body,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (index) => setState(() => _index = index),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.grid_view),
            label: l10n.tabExplore,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.camera_alt),
            label: l10n.tabAr,
          ),
        ],
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/renderer/providers/fractal_provider.dart';
import 'package:flutter_fractals/features/viewer/fractal_viewer_screen.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';

class FractalCatalogScreen extends StatefulWidget {
  const FractalCatalogScreen({Key? key}) : super(key: key);

  @override
  State<FractalCatalogScreen> createState() => _FractalCatalogScreenState();
}

class _FractalCatalogScreenState extends State<FractalCatalogScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final registry = context.read<ModuleRegistry>();
    final l10n = AppLocalizations.of(context)!;

    final query = _searchController.text.trim().toLowerCase();
    final modules = registry.modules.where((module) {
      if (query.isEmpty) {
        return true;
      }
      final name = module.displayName(l10n).toLowerCase();
      return name.contains(query);
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: TextField(
            key: const Key('catalogSearchField'),
            controller: _searchController,
            decoration: InputDecoration(
              hintText: l10n.catalogSearchHint,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                    ),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
        Expanded(
          child: modules.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.search_off, size: 40),
                        const SizedBox(height: 12),
                        Text(
                          l10n.catalogSearchEmpty,
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        if (query.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          TextButton(
                            key: const Key('catalogClearSearchButton'),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                            child: Text(l10n.actionClearSearch),
                          ),
                        ],
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: modules.length,
                  itemBuilder: (context, index) {
                    final module = modules[index];
                    return _ModuleCard(
                      module: module,
                      onTap: () {
                        final controller = context.read<FractalController>();
                        controller.selectModule(module);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ChangeNotifierProvider.value(
                              value: controller,
                              child: const FractalViewerScreen(),
                            ),
                          ),
                        );
                      },
                      l10n: l10n,
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final FractalModule module;
  final VoidCallback onTap;
  final AppLocalizations l10n;

  const _ModuleCard({
    required this.module,
    required this.onTap,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final dimensionLabel =
        module.dimension == FractalDimension.twoD ? l10n.dimension2d : l10n.dimension3d;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        title: Text(module.displayName(l10n)),
        subtitle: Text(dimensionLabel),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

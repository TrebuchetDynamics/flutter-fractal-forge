import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/services/accessibility_service.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/features/catalog/catalog_entry.dart';
import 'package:flutter_fractals/features/catalog/catalog_repository.dart';
import 'package:flutter_fractals/core/widgets/animated_widgets.dart';
import 'package:flutter_fractals/features/renderer/providers/fractal_provider.dart';
import 'package:flutter_fractals/features/viewer/fractal_viewer_screen.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';

enum CatalogViewMode { grid, list }

enum _DimensionFilter { all, twoD, threeD }

enum _SortOrder { byCategory, alphabetical }

/// IDs (without 'core.' prefix) that have a known thumbnail PNG.
const _kKnownThumbnailIds = <String>{
  // Original set
  'mandelbrot', 'julia', 'burning_ship', 'burning_ship_julia', 'buffalo',
  'buffalo_julia', 'manowar', 'celtic', 'celtic_julia', 'cosine_mandelbrot',
  'cosine_julia', 'cosh_mandelbrot', 'lambda', 'glynn', 'magnet_type_2',
  'magnet_newton', 'halley', 'householder', 'legendre', 'laguerre',
  'chebyshev', 'eisenstein', 'fatou', 'exponential', 'dual_complex',
  'bicomplex', 'hypercomplex_newton', 'collatz', 'gamma_fractal', 'ducky',
  'fish', 'druid', 'heart', 'day_night', 'barnsley_fern', 'barnsley_j1',
  'barnsley_j2', 'barnsley_j3', 'cyclosorus_fern', 'arnold_cat', 'henon',
  'hopalong', 'clifford', 'gumowski_mira', 'gingerbreadman', 'duffing',
  'lyapunov', 'logistic_lyapunov', 'circle_map_lyapunov', 'gauss_map',
  'feigenbaum', 'lorenz_2d', 'aizawa', 'arneodo', 'bouali', 'burke_shaw',
  'chen', 'chua_circuit', 'dadras', 'four_wing', 'hadley', 'halvorsen',
  'liu_chen', 'lu_chen', 'golden_dragon', 'fibonacci_spiral',
  'fibonacci_word', 'log_spiral', 'astroid', 'hilbert_curve', 'gosper_curve',
  'levy_c_curve', 'moore_curve', 'cesaro_fractal', 'fractal_canopy',
  'koch_snowflake', 'hexaflake', 'cantor_set', 'cantor_dust',
  'menger_sponge_2d', 'menger_3d_slice', 'apollonian_gasket', 'ford_circles',
  'farey_diagram', 'cayley_graph', 'ammann_beenker', 'hat_monotile',
  'chair_tiling', 'cactus', 'dla', 'eden_growth', 'forest_fire',
  'langton_ant', 'brian_brain', 'kicked_rotator', 'benesi',
  'anti_buddhabrot', 'buddhabrot_approx', 'manair_fire', 'jerusalem_cube',
  // Additional thumbnails present in assets/catalog_thumbs/
  'deltoid', 'dragon_curve', 'genesio_tesi', 'greek_cross_fractal',
  'hermite', 'highlife', 'ikeda', 'inverse_mandelbrot', 'koch_anti_snowflake',
  'lambda_w', 'levy_tapestry', 'lozi', 'magnet_type_1', 'magnet_type_3',
  'mcworter_pentigree', 'moore_spiegel', 'multibrot3', 'multibrot4',
  'multibrot5', 'multibrot_neg2', 'nebulabrot', 'newton_general',
  'newton_leipnik', 'newton_sin', 'newton_z3', 'nose_hoover', 'nova',
  'nova_julia', 'peano_curve', 'penrose_tiling', 'pentaflake', 'percolation',
  'perpendicular_julia', 'perpendicular_mandelbrot', 'peter_de_jong',
  'phoenix', 'pickover_biomorph', 'pinwheel_tiling', 'pola_sierpinski',
  'popcorn', 'popcorn2', 'power_sum', 'pseudo_kleinian', 'pythagorean_tree',
  'quadratic_koch_island', 'quaternion_julia_2d', 'rabinovich_fabrikant',
  'rational_map', 'rauzy_fractal', 'riemann_zeta', 'rikitake', 'rossler_2d',
  'sandpile', 'schroeder', 'scroll_waves', 'secant_cosecant', 'secant_fractal',
  'shark_fin', 'sierpinski_arrowhead', 'sierpinski_carpet',
  'sierpinski_pentagon', 'sierpinski_tetrahedron', 'sierpinski_triangle',
  'simonbrot', 'sine_julia', 'sine_map_lyapunov', 'sinh_cosh',
  'sinh_mandelbrot', 'spectre_monotile', 'sphinx_tiling', 'spider',
  'spider_x', 'split_complex', 'sprott_a', 'standard_map', 'steiner_chain',
  'svensson', 'talis', 'tangent', 'tangent_mandelbrot', 'tanh_mandelbrot',
  'taylor', 'tent_map', 'terdragon', 'tessarine_julia', 'tetration',
  'thomas_attractor', 'tinkerbell', 'tricorn', 'tricorn_julia', 'turmite',
  'twin_dragon', 'vicsek_fractal', 'virial', 'wireworld', 'wolfram_rule30',
  'zaslavsky', 'zircon_zity', 'z_order_curve',
};

class FractalCatalogScreen extends StatefulWidget {
  const FractalCatalogScreen({Key? key}) : super(key: key);

  @override
  State<FractalCatalogScreen> createState() => _FractalCatalogScreenState();
}

class _FractalCatalogScreenState extends State<FractalCatalogScreen> {
  static const _viewPrefKey = 'catalog_view_grid';

  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;
  bool _isSearchFocused = false;
  CatalogViewMode _viewMode = CatalogViewMode.grid;
  _DimensionFilter _dimensionFilter = _DimensionFilter.all;
  _SortOrder _sortOrder = _SortOrder.byCategory;

  // Cached catalog — rebuilt only when registry changes.
  CatalogRepository? _catalog;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isSearchFocused = _focusNode.hasFocus);
    });
    _loadViewPreference();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final registry = context.read<ModuleRegistry>();
    // Only rebuild if not yet initialised (registry is effectively immutable
    // after app start, so identity check is sufficient).
    _catalog ??= CatalogRepository.fromRegistry(registry);
  }

  Future<void> _loadViewPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final useGrid = prefs.getBool(_viewPrefKey) ?? true;
    if (!mounted) return;
    setState(() {
      _viewMode = useGrid ? CatalogViewMode.grid : CatalogViewMode.list;
    });
  }

  Future<void> _setViewMode(CatalogViewMode mode) async {
    setState(() => _viewMode = mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_viewPrefKey, mode == CatalogViewMode.grid);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  List<CatalogEntry> _filteredEntries(AppLocalizations l10n) {
    final query = _searchController.text.trim().toLowerCase();
    return _catalog!.entries.where((entry) {
      // Dimension filter
      if (_dimensionFilter == _DimensionFilter.twoD &&
          entry.module.dimension != FractalDimension.twoD) return false;
      if (_dimensionFilter == _DimensionFilter.threeD &&
          entry.module.dimension != FractalDimension.threeD) return false;

      // Search query
      if (query.isEmpty) return true;
      final name = entry.module.displayName(l10n).toLowerCase();
      final matchesAlias =
          entry.aliases.any((a) => a.toLowerCase().contains(query));
      return name.contains(query) ||
          matchesAlias ||
          entry.catalogId.contains(query) ||
          entry.category.toLowerCase().contains(query);
    }).toList();
  }

  Map<String, List<CatalogEntry>> _groupAndSort(
      List<CatalogEntry> entries, AppLocalizations l10n) {
    if (_sortOrder == _SortOrder.alphabetical) {
      final sorted = List<CatalogEntry>.from(entries)
        ..sort((a, b) =>
            a.module.displayName(l10n).compareTo(b.module.displayName(l10n)));
      return {'All Fractals': sorted};
    }

    final grouped = <String, List<CatalogEntry>>{};
    for (final entry in entries) {
      grouped.putIfAbsent(entry.category, () => []).add(entry);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final query = _searchController.text.trim().toLowerCase();
    final allEntries = _filteredEntries(l10n);
    final groupedEntries = _groupAndSort(allEntries, l10n);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildSearchField(context, l10n)),
              const SizedBox(width: AppSpacing.sm),
              _buildViewToggle(context, l10n),
            ],
          ),
        ),
        _buildFilterAndSortBar(context, l10n),
        Expanded(
          child: allEntries.isEmpty
              ? _EmptyState(
                  query: query,
                  l10n: l10n,
                  onClear: () {
                    _searchController.clear();
                    setState(() {});
                  },
                )
              : _viewMode == CatalogViewMode.grid
                  ? _buildGridContent(context, groupedEntries, l10n)
                  : _buildListContent(context, groupedEntries, l10n),
        ),
      ],
    );
  }

  Widget _buildFilterAndSortBar(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          // Dimension filters
          _DimChip(
            label: 'All',
            selected: _dimensionFilter == _DimensionFilter.all,
            onTap: () =>
                setState(() => _dimensionFilter = _DimensionFilter.all),
          ),
          const SizedBox(width: AppSpacing.xs),
          _DimChip(
            label: '2D',
            selected: _dimensionFilter == _DimensionFilter.twoD,
            onTap: () =>
                setState(() => _dimensionFilter = _DimensionFilter.twoD),
          ),
          const SizedBox(width: AppSpacing.xs),
          _DimChip(
            label: '3D',
            selected: _dimensionFilter == _DimensionFilter.threeD,
            onTap: () =>
                setState(() => _dimensionFilter = _DimensionFilter.threeD),
          ),
          const Spacer(),
          // Sort dropdown
          PopupMenuButton<_SortOrder>(
            tooltip: 'Sort order',
            initialValue: _sortOrder,
            onSelected: (value) => setState(() => _sortOrder = value),
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: _SortOrder.byCategory,
                child: Text('By Category'),
              ),
              const PopupMenuItem(
                value: _SortOrder.alphabetical,
                child: Text('Alphabetical A-Z'),
              ),
            ],
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.sort_rounded, size: 16, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Text(
                  _sortOrder == _SortOrder.byCategory ? 'By Category' : 'A-Z',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                Icon(Icons.arrow_drop_down,
                    size: 18, color: AppColors.textMuted),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(BuildContext context, AppLocalizations l10n) {
    return AnimatedContainer(
      duration: AppAnimations.normal,
      curve: AppAnimations.defaultCurve,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
        border: Border.all(
          color: _isSearchFocused
              ? AppColors.primary.withOpacity(0.6)
              : AppColors.border.withOpacity(0.3),
          width: _isSearchFocused ? 1.5 : 1,
        ),
        boxShadow: _isSearchFocused
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.15),
                  blurRadius: 12,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: TextField(
        key: const Key('catalogSearchField'),
        controller: _searchController,
        focusNode: _focusNode,
        style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: l10n.catalogSearchHint,
          hintStyle:
              AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
          prefixIcon: AnimatedContainer(
            duration: AppAnimations.fast,
            child: Icon(
              Icons.search_rounded,
              color:
                  _isSearchFocused ? AppColors.primary : AppColors.textMuted,
            ),
          ),
          suffixIcon: AnimatedSwitcher(
            duration: AppAnimations.fast,
            child: _searchController.text.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
                    key: const ValueKey('clear'),
                    tooltip:
                        MaterialLocalizations.of(context).deleteButtonTooltip,
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                  ),
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
        ),
        onChanged: (_) {
          _debounce?.cancel();
          _debounce = Timer(const Duration(milliseconds: 200), () {
            setState(() {});
          });
        },
      ),
    );
  }

  Widget _buildViewToggle(BuildContext context, AppLocalizations l10n) {
    final isGrid = _viewMode == CatalogViewMode.grid;
    return Semantics(
      button: true,
      label: isGrid ? 'Switch to list view' : 'Switch to grid view',
      child: Tooltip(
        message: isGrid ? 'List view' : 'Grid view',
        child: IconButton(
          key: const Key('catalogViewToggleButton'),
          onPressed: () => _setViewMode(
            isGrid ? CatalogViewMode.list : CatalogViewMode.grid,
          ),
          icon: Icon(
            isGrid ? Icons.view_list_rounded : Icons.grid_view_rounded,
            color: AppColors.textMuted,
            size: 22,
          ),
        ),
      ),
    );
  }

  Widget _buildListContent(
    BuildContext context,
    Map<String, List<CatalogEntry>> groupedEntries,
    AppLocalizations l10n,
  ) {
    final flatItems =
        <({String type, CatalogEntry? entry, String? title, int count})>[];
    for (final section in groupedEntries.entries) {
      flatItems.add((
        type: 'header',
        entry: null,
        title: section.key,
        count: section.value.length
      ));
      for (final entry in section.value) {
        flatItems.add((type: 'card', entry: entry, title: null, count: 0));
      }
      flatItems.add((type: 'spacer', entry: null, title: null, count: 0));
    }

    return ListView.builder(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.sm,
        bottom: MediaQuery.of(context).padding.bottom + 100,
      ),
      itemCount: flatItems.length,
      itemBuilder: (context, index) {
        final item = flatItems[index];
        switch (item.type) {
          case 'header':
            return _SectionHeader(title: item.title!, count: item.count);
          case 'card':
            return _ModuleCard(
              entry: item.entry!,
              onTap: () => _openViewer(context, item.entry!.module),
              l10n: l10n,
            );
          case 'spacer':
            return const SizedBox(height: AppSpacing.lg);
          default:
            return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildGridContent(
    BuildContext context,
    Map<String, List<CatalogEntry>> groupedEntries,
    AppLocalizations l10n,
  ) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width >= 1024
        ? 6
        : width >= 840
            ? 5
            : width >= 600
                ? 4
                : 3;

    return ListView(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.sm,
        bottom: MediaQuery.of(context).padding.bottom + 100,
      ),
      children: groupedEntries.entries.map((section) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(title: section.key, count: section.value.length),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: section.value.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: AppSpacing.xs,
                mainAxisSpacing: AppSpacing.xs,
                childAspectRatio: 0.82,
              ),
              itemBuilder: (context, index) {
                final entry = section.value[index];
                return _ModuleGridTile(
                  entry: entry,
                  l10n: l10n,
                  onTap: () => _openViewer(context, entry.module),
                );
              },
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        );
      }).toList(growable: false),
    );
  }

  void _openViewer(BuildContext context, FractalModule module) {
    final controller = context.read<FractalController>();
    controller.selectModule(module);
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: controller),
          ],
          child: const FractalViewerScreen(),
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: AppAnimations.defaultCurve,
          );
          return FadeTransition(
            opacity: curvedAnimation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.05),
                end: Offset.zero,
              ).animate(curvedAnimation),
              child: child,
            ),
          );
        },
        transitionDuration: AppAnimations.normal,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared section header with colored left border and count badge
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;

  const _SectionHeader({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.md,
        bottom: AppSpacing.sm,
      ),
      child: Row(
        children: [
          // Colored left accent border
          Container(
            width: 3,
            height: 20,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              title,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ),
          // Count badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Dimension filter chip
// ---------------------------------------------------------------------------

class _DimChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _DimChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppAnimations.fast,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withOpacity(0.18)
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppColors.primary.withOpacity(0.5)
                : AppColors.border.withOpacity(0.3),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: selected ? AppColors.primary : AppColors.textSecondary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Grid tile with elevation, gradient overlay, and better text readability
// ---------------------------------------------------------------------------

class _ModuleGridTile extends StatelessWidget {
  final CatalogEntry entry;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  const _ModuleGridTile({
    required this.entry,
    required this.l10n,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final is3D = entry.module.dimension == FractalDimension.threeD;
    final dimensionLabel = is3D ? l10n.dimension3d : l10n.dimension2d;
    final name = entry.module.displayName(l10n);

    return Semantics(
      label: l10n.semanticFractalCard(name, dimensionLabel),
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: Key('catalogGridTile_${entry.catalogId}'),
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Thumbnail (fills the tile)
                  _PreviewThumbnail(
                    catalogId: entry.catalogId,
                    is3D: is3D,
                    category: entry.category,
                  ),
                  // Gradient overlay for text readability
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(6, 16, 6, 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.72),
                          ],
                        ),
                      ),
                      child: Text(
                        name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: AppTypography.labelSmall.copyWith(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          shadows: [
                            const Shadow(
                              color: Colors.black54,
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  final String query;
  final AppLocalizations l10n;
  final VoidCallback onClear;

  const _EmptyState({
    required this.query,
    required this.l10n,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return FadeIn(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.search_off_rounded,
                  size: 36,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                l10n.catalogSearchEmpty,
                style: AppTypography.bodyLarge
                    .copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              if (query.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                TextButton.icon(
                  key: const Key('catalogClearSearchButton'),
                  onPressed: onClear,
                  icon: const Icon(Icons.close_rounded, size: 18),
                  label: Text(l10n.actionClearSearch),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// List-mode card
// ---------------------------------------------------------------------------

class _ModuleCard extends StatefulWidget {
  final CatalogEntry entry;
  final VoidCallback onTap;
  final AppLocalizations l10n;

  const _ModuleCard({
    required this.entry,
    required this.onTap,
    required this.l10n,
  });

  @override
  State<_ModuleCard> createState() => _ModuleCardState();
}

class _ModuleCardState extends State<_ModuleCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.fast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: AppAnimations.snappyCurve),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final is3D = widget.entry.module.dimension == FractalDimension.threeD;
    final dimensionLabel =
        is3D ? widget.l10n.dimension3d : widget.l10n.dimension2d;
    final name = widget.entry.module.displayName(widget.l10n);
    final semanticLabel =
        widget.l10n.semanticFractalCard(name, dimensionLabel);

    final reduceMotion = MediaQuery.of(context).disableAnimations ||
        (context.read<AccessibilityService?>()?.reducedMotionEnabled ?? false);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Semantics(
        label: semanticLabel,
        button: true,
        child: GestureDetector(
          key: Key('catalogModuleCard_${widget.entry.catalogId}'),
          onTapDown: reduceMotion
              ? null
              : (_) {
                  setState(() => _isPressed = true);
                  _controller.forward();
                },
          onTapUp: reduceMotion
              ? null
              : (_) {
                  setState(() => _isPressed = false);
                  _controller.reverse();
                },
          onTapCancel: reduceMotion
              ? null
              : () {
                  setState(() => _isPressed = false);
                  _controller.reverse();
                },
          onTap: widget.onTap,
          child: reduceMotion
              ? _buildCardContent(dimensionLabel, is3D)
              : ScaleTransition(
                  scale: _scaleAnimation,
                  child: _buildCardContent(dimensionLabel, is3D),
                ),
        ),
      ),
    );
  }

  Widget _buildCardContent(String dimensionLabel, bool is3D) {
    return AnimatedContainer(
      duration: AppAnimations.fast,
      decoration: BoxDecoration(
        color: _isPressed ? AppColors.surfaceElevated : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(
          color: _isPressed
              ? AppColors.primary.withOpacity(0.4)
              : AppColors.border.withOpacity(0.4),
        ),
        boxShadow: _isPressed
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.1),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        child: Row(
          children: [
            _PreviewThumbnail(
              catalogId: widget.entry.catalogId,
              is3D: is3D,
              category: widget.entry.category,
              size: 48,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.entry.module.displayName(widget.l10n),
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dimensionLabel,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: AppAnimations.fast,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _isPressed
                    ? AppColors.primary.withOpacity(0.2)
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.arrow_forward_rounded,
                size: 18,
                color: _isPressed ? AppColors.primary : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Category color helpers
// ---------------------------------------------------------------------------

/// Returns the accent color for a given fractal category string.
Color _categoryAccentColor(String category) {
  final cat = category.toLowerCase();
  if (cat.contains('escape')) return const Color(0xFF5B6FD4);
  if (cat.contains('complex')) return const Color(0xFF9B59B6);
  if (cat.contains('rational')) return const Color(0xFFE67E22);
  if (cat.contains('attract')) return const Color(0xFF27AE60);
  if (cat.contains('cellular') || cat.contains('automata')) {
    return const Color(0xFF7F8C8D);
  }
  if (cat.contains('root') || cat.contains('finder')) {
    return const Color(0xFF00BCD4);
  }
  if (cat.contains('julia')) return const Color(0xFFE040FB);
  if (cat.contains('flame')) return const Color(0xFFFF5722);
  if (cat.contains('buddhabrot')) return const Color(0xFF7C4DFF);
  if (cat.contains('simulation')) return const Color(0xFF009688);
  if (cat.contains('3d')) return const Color(0xFFFFB300);
  return const Color(0xFF2980B9);
}

// ---------------------------------------------------------------------------
// Preview thumbnail with shimmer, improved badge, and category accent bar
// ---------------------------------------------------------------------------

class _PreviewThumbnail extends StatefulWidget {
  final String catalogId;
  final bool is3D;
  final String category;
  final double? size;

  const _PreviewThumbnail({
    required this.catalogId,
    required this.is3D,
    required this.category,
    this.size,
  });

  @override
  State<_PreviewThumbnail> createState() => _PreviewThumbnailState();
}

class _PreviewThumbnailState extends State<_PreviewThumbnail>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerController;
  bool _imageLoaded = false;
  bool _imageError = false;

  bool get _hasExactCpuThumbnail {
    final thumbId = widget.catalogId.startsWith('core.')
        ? widget.catalogId.substring(5)
        : widget.catalogId;
    return _kKnownThumbnailIds.contains(thumbId);
  }

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final thumbId = widget.catalogId.startsWith('core.')
        ? widget.catalogId.substring(5)
        : widget.catalogId;
    final thumbAsset = 'assets/catalog_thumbs/$thumbId.png';
    final isApproximate = !_hasExactCpuThumbnail;
    final accentColor = _categoryAccentColor(widget.category);

    return Container(
      width: widget.size ?? double.infinity,
      height: widget.size ?? double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Shimmer shown while image is loading
          if (!_imageLoaded && !_imageError)
            _ShimmerSkeleton(controller: _shimmerController),

          // Image (or gradient fallback on error)
          Positioned.fill(
            child: Image.asset(
              thumbAsset,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.medium,
              frameBuilder:
                  (context, child, frame, wasSynchronouslyLoaded) {
                if (frame != null && !_imageLoaded) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) setState(() => _imageLoaded = true);
                  });
                }
                return AnimatedOpacity(
                  opacity: frame != null ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 250),
                  child: child,
                );
              },
              errorBuilder: (context, error, stack) {
                if (!_imageError) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) setState(() => _imageError = true);
                  });
                }
                return _GradientFallback(
                  catalogId: widget.catalogId,
                  category: widget.category,
                );
              },
            ),
          ),

          // Category accent bar — 3px strip at top edge
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 3,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.85),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
            ),
          ),

          // Dimension badge — pill shape, amber for 3D, subtle for 2D
          Positioned(
            top: 7,
            right: 6,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: widget.is3D
                    ? const Color(0xFFFFB300).withOpacity(0.92)
                    : Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: widget.is3D
                      ? const Color(0xFFFFB300)
                      : Colors.white.withOpacity(0.45),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Text(
                widget.is3D ? '3D' : '2D',
                style: AppTypography.labelSmall.copyWith(
                  color: widget.is3D ? Colors.black87 : Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 10,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),

          // "Preview approximate" label
          if (isApproximate)
            Positioned(
              bottom: 4,
              left: 4,
              right: 4,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Preview approximate',
                  textAlign: TextAlign.center,
                  style: AppTypography.labelSmall.copyWith(
                    color: Colors.white70,
                    fontSize: 9,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shimmer skeleton shown while thumbnail image is loading
// ---------------------------------------------------------------------------

class _ShimmerSkeleton extends StatelessWidget {
  final AnimationController controller;
  const _ShimmerSkeleton({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final shimmerPos = controller.value * 2 - 0.5;
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) => LinearGradient(
            begin: Alignment(shimmerPos - 1, -0.3),
            end: Alignment(shimmerPos, 0.3),
            colors: const [
              Color(0xFF2A2A3A),
              Color(0xFF3E3E54),
              Color(0xFF4A4A62),
              Color(0xFF3E3E54),
              Color(0xFF2A2A3A),
            ],
            stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
          ).createShader(bounds),
          child: const DecoratedBox(
            decoration: BoxDecoration(color: Color(0xFF2A2A3A)),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Category-aware gradient fallback using CustomPainter
// ---------------------------------------------------------------------------

class _GradientFallback extends StatelessWidget {
  final String catalogId;
  final String category;

  const _GradientFallback({
    required this.catalogId,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _FractalGradientPainter(
        catalogId: catalogId,
        category: category,
      ),
    );
  }
}

class _FractalGradientPainter extends CustomPainter {
  final String catalogId;
  final String category;

  const _FractalGradientPainter({
    required this.catalogId,
    required this.category,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final cat = category.toLowerCase();
    final hash = catalogId.hashCode.abs();

    if (cat.contains('escape')) {
      _paintEscapeTime(canvas, rect, hash);
    } else if (cat.contains('complex')) {
      _paintComplexViz(canvas, rect, hash);
    } else if (cat.contains('rational')) {
      _paintRationalMaps(canvas, rect, hash);
    } else if (cat.contains('attract')) {
      _paintAttractors(canvas, rect, hash);
    } else if (cat.contains('cellular') || cat.contains('automata')) {
      _paintCellular(canvas, rect, hash);
    } else if (cat.contains('root') || cat.contains('finder')) {
      _paintRootFinder(canvas, rect, hash);
    } else if (cat.contains('julia')) {
      _paintJulia(canvas, rect, hash);
    } else if (cat.contains('flame')) {
      _paintFractalFlame(canvas, rect, hash);
    } else if (cat.contains('buddhabrot')) {
      _paintBuddhabrot(canvas, rect, hash);
    } else if (cat.contains('simulation')) {
      _paintSimulation(canvas, rect, hash);
    } else if (cat.contains('3d')) {
      _paint3D(canvas, rect, hash);
    } else {
      _paintDefault(canvas, rect, hash);
    }
  }

  /// Deep blue/purple with radial glow (Escape-Time fractals).
  void _paintEscapeTime(Canvas canvas, Rect rect, int hash) {
    canvas.drawRect(rect, Paint()..color = const Color(0xFF040820));

    canvas.drawRect(
      rect,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment.center,
          radius: 1.0,
          colors: [
            Color(0xFF3B1FA0),
            Color(0xFF1A0A50),
            Color(0xFF040820),
          ],
          stops: [0.0, 0.5, 1.0],
        ).createShader(rect),
    );

    final offsetX = (hash % 40 - 20) / 60.0;
    final offsetY = ((hash ~/ 37) % 40 - 20) / 60.0;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: Alignment(offsetX, offsetY),
          radius: 0.38,
          colors: const [
            Color(0xCCBBDDFF),
            Color(0x885599FF),
            Color(0x003311AA),
          ],
        ).createShader(rect),
    );

    final angle = (hash % 60).toDouble() * math.pi / 180;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          transform: GradientRotation(angle),
          colors: const [
            Color(0x004488FF),
            Color(0x336699FF),
            Color(0x004488FF),
          ],
        ).createShader(rect),
    );
  }

  /// Rainbow/spectrum sweep (Complex Visualization).
  void _paintComplexViz(Canvas canvas, Rect rect, int hash) {
    canvas.drawRect(rect, Paint()..color = const Color(0xFF0D0015));

    final sweepAngle = (hash % 45).toDouble() * math.pi / 180;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          transform: GradientRotation(sweepAngle),
          colors: const [
            Color(0xFFFF0080),
            Color(0xFFFF6600),
            Color(0xFFFFDD00),
            Color(0xFF00FF88),
            Color(0xFF0088FF),
            Color(0xFF8800FF),
            Color(0xFFFF0080),
          ],
          stops: [0.0, 0.17, 0.33, 0.5, 0.67, 0.83, 1.0],
        ).createShader(rect),
    );

    canvas.drawRect(
      rect,
      Paint()
        ..shader = const RadialGradient(
          radius: 0.85,
          colors: [
            Color(0x00000000),
            Color(0xAA000000),
          ],
        ).createShader(rect),
    );
  }

  /// Warm red/orange (Rational Maps).
  void _paintRationalMaps(Canvas canvas, Rect rect, int hash) {
    canvas.drawRect(rect, Paint()..color = const Color(0xFF1A0500));

    final cx = (hash % 30 - 20) / 40.0;
    final cy = ((hash ~/ 31) % 30 - 20) / 40.0;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: Alignment(cx, cy),
          radius: 0.85,
          colors: const [
            Color(0xFFFF6B00),
            Color(0xFFCC2200),
            Color(0xFF1A0500),
          ],
          stops: [0.0, 0.45, 1.0],
        ).createShader(rect),
    );

    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0x55FF9900),
            Color(0x00FF5500),
            Color(0x33FF2200),
          ],
        ).createShader(rect),
    );
  }

  /// Green/teal (Attractors).
  void _paintAttractors(Canvas canvas, Rect rect, int hash) {
    canvas.drawRect(rect, Paint()..color = const Color(0xFF010E06));

    final cx = (hash % 40 - 20) / 50.0;
    final cy = ((hash ~/ 41) % 40 - 20) / 50.0;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: Alignment(cx, cy),
          radius: 0.9,
          colors: const [
            Color(0xFF00C864),
            Color(0xFF006644),
            Color(0xFF010E06),
          ],
          stops: [0.0, 0.5, 1.0],
        ).createShader(rect),
    );

    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0x4400E5CC),
            Color(0x0000CC99),
            Color(0x2200AAAA),
          ],
        ).createShader(rect),
    );
  }

  /// Monochrome geometric (Cellular Automata).
  void _paintCellular(Canvas canvas, Rect rect, int hash) {
    canvas.drawRect(rect, Paint()..color = const Color(0xFF111111));

    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF2E2E2E),
            Color(0xFF111111),
          ],
        ).createShader(rect),
    );

    final linePaint = Paint()
      ..color = const Color(0x22FFFFFF)
      ..strokeWidth = 0.8;

    final step = 8.0 + (hash % 6).toDouble();
    for (double x = 0; x < rect.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, rect.height), linePaint);
    }
    for (double y = 0; y < rect.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(rect.width, y), linePaint);
    }

    final accentPaint = Paint()..color = const Color(0x44FFFFFF);
    final cols = (rect.width / step).floor();
    final rows = (rect.height / step).floor();
    if (cols > 0 && rows > 0) {
      for (int i = 0; i < 6; i++) {
        final col =
            ((hash ~/ math.pow(3, i).toInt()) % cols).toDouble() * step;
        final row =
            ((hash ~/ math.pow(5, i).toInt()) % rows).toDouble() * step;
        canvas.drawRect(
            Rect.fromLTWH(col, row, step - 1, step - 1), accentPaint);
      }
    }
  }

  /// Cyan/electric-blue voronoi-like pattern (Root Finder / Newton basins).
  void _paintRootFinder(Canvas canvas, Rect rect, int hash) {
    canvas.drawRect(rect, Paint()..color = const Color(0xFF000D1A));

    final cx = (hash % 30 - 15) / 40.0;
    final cy = ((hash ~/ 29) % 30 - 15) / 40.0;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: Alignment(cx, cy),
          radius: 0.75,
          colors: const [
            Color(0xFF00E5FF),
            Color(0xFF0088CC),
            Color(0xFF000D1A),
          ],
          stops: [0.0, 0.45, 1.0],
        ).createShader(rect),
    );

    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0x5500CFFF),
            Color(0x000066AA),
            Color(0x3300AADD),
          ],
        ).createShader(rect),
    );

    canvas.drawRect(
      rect,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(0.0, 0.0),
          radius: 0.5,
          colors: [
            Color(0x00000000),
            Color(0x99000D1A),
          ],
        ).createShader(rect),
    );
  }

  /// Purple/magenta spiral gradient (Julia sets).
  void _paintJulia(Canvas canvas, Rect rect, int hash) {
    canvas.drawRect(rect, Paint()..color = const Color(0xFF0A0015));

    final angle = (hash % 72).toDouble() * math.pi / 180;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          transform: GradientRotation(angle),
          colors: const [
            Color(0xFFAA00FF),
            Color(0xFF5500CC),
            Color(0xFF1A0040),
          ],
          stops: [0.0, 0.5, 1.0],
        ).createShader(rect),
    );

    final cx = (hash % 40 - 20) / 50.0;
    final cy = ((hash ~/ 43) % 40 - 20) / 50.0;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: Alignment(cx, cy),
          radius: 0.55,
          colors: const [
            Color(0xCCFF40FF),
            Color(0x88CC00CC),
            Color(0x000A0015),
          ],
        ).createShader(rect),
    );

    canvas.drawRect(
      rect,
      Paint()
        ..shader = const RadialGradient(
          radius: 0.9,
          colors: [Color(0x00000000), Color(0xBB0A0015)],
        ).createShader(rect),
    );
  }

  /// Warm fire gradient (Fractal Flame / IFS flame).
  void _paintFractalFlame(Canvas canvas, Rect rect, int hash) {
    canvas.drawRect(rect, Paint()..color = const Color(0xFF0A0000));

    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Color(0xFF220000),
            Color(0xFFAA2200),
            Color(0xFFFF6600),
            Color(0xFFFFCC00),
          ],
          stops: [0.0, 0.35, 0.7, 1.0],
        ).createShader(rect),
    );

    final bx = (hash % 30 - 15) / 40.0;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: Alignment(bx, 0.2),
          radius: 0.55,
          colors: const [
            Color(0xAAFFAA00),
            Color(0x55FF4400),
            Color(0x000A0000),
          ],
        ).createShader(rect),
    );

    canvas.drawRect(
      rect,
      Paint()
        ..shader = const RadialGradient(
          radius: 0.95,
          colors: [Color(0x00000000), Color(0xCC0A0000)],
        ).createShader(rect),
    );
  }

  /// Dark background with nebula-like glow (Buddhabrot).
  void _paintBuddhabrot(Canvas canvas, Rect rect, int hash) {
    canvas.drawRect(rect, Paint()..color = const Color(0xFF02010A));

    final cx = (hash % 20 - 10) / 30.0;
    final cy = ((hash ~/ 23) % 20 - 10) / 30.0;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: Alignment(cx, cy),
          radius: 0.65,
          colors: const [
            Color(0xFF5533AA),
            Color(0xFF221166),
            Color(0xFF02010A),
          ],
          stops: [0.0, 0.5, 1.0],
        ).createShader(rect),
    );

    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: Alignment(-cx * 0.6, -cy * 0.6),
          radius: 0.35,
          colors: const [
            Color(0x994488FF),
            Color(0x332255BB),
            Color(0x0002010A),
          ],
        ).createShader(rect),
    );

    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0x337700CC),
            Color(0x00000000),
            Color(0x224400AA),
          ],
        ).createShader(rect),
    );
  }

  /// Organic green/cyan pattern (Simulation / Reaction-Diffusion).
  void _paintSimulation(Canvas canvas, Rect rect, int hash) {
    canvas.drawRect(rect, Paint()..color = const Color(0xFF000E0C));

    final angle = (hash % 45).toDouble() * math.pi / 180;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          transform: GradientRotation(angle),
          colors: const [
            Color(0xFF006655),
            Color(0xFF00332A),
            Color(0xFF000E0C),
          ],
          stops: [0.0, 0.55, 1.0],
        ).createShader(rect),
    );

    final cx = (hash % 40 - 20) / 55.0;
    final cy = ((hash ~/ 37) % 40 - 20) / 55.0;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: Alignment(cx, cy),
          radius: 0.6,
          colors: const [
            Color(0xFF00DDAA),
            Color(0xFF009977),
            Color(0x00000E0C),
          ],
          stops: [0.0, 0.4, 1.0],
        ).createShader(rect),
    );

    canvas.drawRect(
      rect,
      Paint()
        ..shader = const RadialGradient(
          radius: 0.88,
          colors: [Color(0x00000000), Color(0xCC000E0C)],
        ).createShader(rect),
    );
  }

  /// Metallic silver/dark gradient with depth effect (3D fractals).
  void _paint3D(Canvas canvas, Rect rect, int hash) {
    canvas.drawRect(rect, Paint()..color = const Color(0xFF080A0E));

    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF3A3F4A),
            Color(0xFF1A1E26),
            Color(0xFF080A0E),
          ],
          stops: [0.0, 0.5, 1.0],
        ).createShader(rect),
    );

    final cx = (hash % 30 - 15) / 35.0;
    final cy = ((hash ~/ 31) % 30 - 15) / 35.0;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: Alignment(cx, cy),
          radius: 0.6,
          colors: const [
            Color(0xCCC8D0DC),
            Color(0x888899AA),
            Color(0x00080A0E),
          ],
        ).createShader(rect),
    );

    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
          colors: [
            Color(0x44445566),
            Color(0x00000000),
            Color(0x22334455),
          ],
        ).createShader(rect),
    );
  }

  /// Default — HSV-based with overlapping gradients for depth.
  void _paintDefault(Canvas canvas, Rect rect, int hash) {
    final hueA = (hash % 360).toDouble();
    final hueB = ((hash ~/ 11) % 360).toDouble();
    final colorA = HSVColor.fromAHSV(1, hueA, 0.58, 0.92).toColor();
    final colorB = HSVColor.fromAHSV(1, hueB, 0.66, 0.78).toColor();
    final colorMid =
        HSVColor.fromAHSV(1, (hueA + hueB) / 2, 0.72, 0.55).toColor();

    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colorA, colorB],
        ).createShader(rect),
    );

    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.3),
          radius: 0.9,
          colors: [
            colorMid.withOpacity(0.55),
            Colors.transparent,
          ],
        ).createShader(rect),
    );

    final angle = (hash % 90).toDouble() * math.pi / 180;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          transform: GradientRotation(angle),
          colors: [
            colorB.withOpacity(0.4),
            Colors.transparent,
            colorA.withOpacity(0.3),
          ],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_FractalGradientPainter old) =>
      old.catalogId != catalogId || old.category != category;
}

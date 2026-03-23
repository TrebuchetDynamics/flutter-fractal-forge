import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/services/accessibility_service.dart';
import 'package:flutter_fractals/core/services/runtime_mode_service.dart';
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

/// Featured fractal IDs shown in the hero carousel at the top of the catalog.
const _kFeaturedFractalIds = <String>[
  'mandelbrot',
  'julia',
  'burning_ship',
  'newton_z3',
  'mandelbulb',
  'buddhabrot',
  'sierpinski_triangle',
  'barnsley_fern',
];

/// IDs (without 'core.' prefix) that have a known thumbnail PNG.
const _kKnownThumbnailIds = <String>{
  'mandelbrot',
  'julia',
  'burning_ship',
  'burning_ship_julia',
  'buffalo',
  'buffalo_julia',
  'manowar',
  'celtic',
  'celtic_julia',
  'cosine_mandelbrot',
  'cosine_julia',
  'cosh_mandelbrot',
  'lambda',
  'glynn',
  'magnet_type_2',
  'magnet_newton',
  'halley',
  'householder',
  'legendre',
  'laguerre',
  'chebyshev',
  'eisenstein',
  'fatou',
  'exponential',
  'dual_complex',
  'bicomplex',
  'hypercomplex_newton',
  'collatz',
  'gamma_fractal',
  'ducky',
  'fish',
  'druid',
  'heart',
  'day_night',
  'barnsley_fern',
  'barnsley_j1',
  'barnsley_j2',
  'barnsley_j3',
  'cyclosorus_fern',
  'arnold_cat',
  'henon',
  'hopalong',
  'clifford',
  'gumowski_mira',
  'gingerbreadman',
  'duffing',
  'lyapunov',
  'logistic_lyapunov',
  'circle_map_lyapunov',
  'gauss_map',
  'feigenbaum',
  'lorenz_2d',
  'aizawa',
  'arneodo',
  'bouali',
  'burke_shaw',
  'chen',
  'chua_circuit',
  'dadras',
  'four_wing',
  'hadley',
  'halvorsen',
  'liu_chen',
  'lu_chen',
  'golden_dragon',
  'fibonacci_spiral',
  'fibonacci_word',
  'log_spiral',
  'astroid',
  'hilbert_curve',
  'gosper_curve',
  'levy_c_curve',
  'moore_curve',
  'cesaro_fractal',
  'fractal_canopy',
  'koch_snowflake',
  'hexaflake',
  'cantor_set',
  'cantor_dust',
  'menger_sponge_2d',
  'menger_3d_slice',
  'apollonian_gasket',
  'ford_circles',
  'farey_diagram',
  'cayley_graph',
  'ammann_beenker',
  'hat_monotile',
  'chair_tiling',
  'cactus',
  'dla',
  'eden_growth',
  'forest_fire',
  'langton_ant',
  'brian_brain',
  'kicked_rotator',
  'benesi',
  'anti_buddhabrot',
  'buddhabrot_approx',
  'manair_fire',
  'jerusalem_cube',
};

/// Global shimmer animation controller shared by all thumbnails.
/// Single controller instead of one per thumbnail (350+ savings).
class _GlobalShimmerController {
  static _GlobalShimmerController? _instance;
  late final AnimationController controller;
  bool _isDisposed = false;

  _GlobalShimmerController(TickerProvider vsync)
      : controller = AnimationController(
          vsync: vsync,
          duration: const Duration(milliseconds: 1500),
        ) {
    controller.repeat();
  }

  factory _GlobalShimmerController.of(TickerProvider vsync) {
    _instance ??= _GlobalShimmerController(vsync);
    return _instance!;
  }

  void dispose() {
    if (!_isDisposed) {
      _isDisposed = true;
      controller.dispose();
      _instance = null;
    }
  }
}

class FractalCatalogScreen extends StatefulWidget {
  const FractalCatalogScreen({Key? key}) : super(key: key);

  @override
  State<FractalCatalogScreen> createState() => _FractalCatalogScreenState();
}

class _FractalCatalogScreenState extends State<FractalCatalogScreen>
    with TickerProviderStateMixin {
  static const _viewPrefKey = 'catalog_view_grid';

  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isSearchFocused = false;
  bool _isSearchVisible = false;
  CatalogViewMode _viewMode = CatalogViewMode.grid;
  _DimensionFilter _dimensionFilter = _DimensionFilter.all;
  _SortOrder _sortOrder = _SortOrder.byCategory;
  String? _selectedCategory;

  // Search debounce - prevents rebuild on every keystroke
  String _debouncedQuery = '';

  // Cached catalog — rebuilt only when registry changes.
  CatalogRepository? _catalog;

  // Global shimmer controller
  late final _GlobalShimmerController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = _GlobalShimmerController.of(this);
    _searchController.addListener(_onSearchChanged);
    _loadViewPreference();
  }

  void _onSearchChanged() {
    // Debounce: only rebuild after 300ms of no typing
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      if (_searchController.text != _debouncedQuery) {
        _debouncedQuery = _searchController.text;
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
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

  bool get _hasActiveCatalogRefinements =>
      _searchController.text.trim().isNotEmpty ||
      _dimensionFilter != _DimensionFilter.all ||
      _selectedCategory != null ||
      _sortOrder != _SortOrder.byCategory;

  bool _matchesDimension(CatalogEntry entry, _DimensionFilter filter) {
    switch (filter) {
      case _DimensionFilter.all:
        return true;
      case _DimensionFilter.twoD:
        return entry.module.dimension == FractalDimension.twoD;
      case _DimensionFilter.threeD:
        return entry.module.dimension == FractalDimension.threeD;
    }
  }

  bool _matchesSearch(
    CatalogEntry entry,
    AppLocalizations l10n,
    String query,
  ) {
    if (query.isEmpty) return true;
    final name = entry.module.displayName(l10n).toLowerCase();
    final matchesAlias =
        entry.aliases.any((alias) => alias.toLowerCase().contains(query));
    return name.contains(query) ||
        matchesAlias ||
        entry.catalogId.contains(query) ||
        entry.category.toLowerCase().contains(query);
  }

  List<CatalogEntry> _entriesMatchingSearch(AppLocalizations l10n) {
    final query = _debouncedQuery.trim().toLowerCase();
    return _catalog!.entries.where((entry) {
      return _matchesSearch(entry, l10n, query);
    }).toList(growable: false);
  }

  List<CatalogEntry> _entriesForDimensionCounts(AppLocalizations l10n) {
    final matchesSearch = _entriesMatchingSearch(l10n);
    return matchesSearch.where((entry) {
      if (_selectedCategory == null) return true;
      return entry.category == _selectedCategory;
    }).toList(growable: false);
  }

  List<CatalogEntry> _entriesForCategoryCounts(AppLocalizations l10n) {
    final matchesSearch = _entriesMatchingSearch(l10n);
    return matchesSearch.where((entry) {
      return _matchesDimension(entry, _dimensionFilter);
    }).toList(growable: false);
  }

  List<CatalogEntry> _filteredEntries(AppLocalizations l10n) {
    final matchesSearchAndDimension = _entriesForCategoryCounts(l10n);
    return matchesSearchAndDimension.where((entry) {
      if (_selectedCategory == null) return true;
      return entry.category == _selectedCategory;
    }).toList(growable: false);
  }

  Map<String, int> _categoryCounts(List<CatalogEntry> entries) {
    final counts = <String, int>{};
    for (final entry in entries) {
      counts.update(entry.category, (count) => count + 1, ifAbsent: () => 1);
    }
    return counts;
  }

  List<String> _sortedCategories(Map<String, int> categoryCounts) {
    final categories = categoryCounts.keys.toList()
      ..sort((a, b) {
        final countCompare = (categoryCounts[b] ?? 0).compareTo(
          categoryCounts[a] ?? 0,
        );
        if (countCompare != 0) return countCompare;
        return a.compareTo(b);
      });

    final selected = _selectedCategory;
    if (selected != null && !categories.contains(selected)) {
      categories.insert(0, selected);
    }

    return categories;
  }

  void _updateDimensionFilter(_DimensionFilter filter) {
    setState(() {
      _dimensionFilter = filter;
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearchVisible = !_isSearchVisible;
      if (!_isSearchVisible) {
        _searchController.clear();
        _focusNode.unfocus();
      } else {
        // Auto focus the search field
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _focusNode.requestFocus();
        });
      }
    });
  }

  void _clearCatalogRefinements() {
    _searchController.clear();
    _focusNode.unfocus();
    setState(() {
      _isSearchVisible = false;
      _dimensionFilter = _DimensionFilter.all;
      _selectedCategory = null;
      _sortOrder = _SortOrder.byCategory;
    });
  }

  Map<String, List<CatalogEntry>> _groupAndSort(
      List<CatalogEntry> entries, AppLocalizations l10n) {
    if (_sortOrder == _SortOrder.alphabetical) {
      final sorted = List<CatalogEntry>.from(entries)
        ..sort((a, b) =>
            a.module.displayName(l10n).compareTo(b.module.displayName(l10n)));
      return {l10n.catalogAllFractals: sorted};
    }

    final grouped = <String, List<CatalogEntry>>{};
    for (final entry in entries) {
      grouped.putIfAbsent(entry.category, () => []).add(entry);
    }

    final sortedEntries = grouped.entries.toList()
      ..sort((a, b) {
        final countCompare = b.value.length.compareTo(a.value.length);
        if (countCompare != 0) return countCompare;
        return a.key.compareTo(b.key);
      });

    return {
      for (final section in sortedEntries)
        section.key: List<CatalogEntry>.from(section.value)
          ..sort((a, b) =>
              a.module.displayName(l10n).compareTo(b.module.displayName(l10n))),
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final query = _debouncedQuery.trim().toLowerCase();
    final filteredEntries = _filteredEntries(l10n);
    final groupedEntries = _groupAndSort(filteredEntries, l10n);
    final categoryBaseEntries = _entriesForCategoryCounts(l10n);
    final categoryCounts = _categoryCounts(categoryBaseEntries);
    final sortedCategories = _sortedCategories(categoryCounts);
    final showFeatured = query.isEmpty &&
        _dimensionFilter == _DimensionFilter.all &&
        _selectedCategory == null &&
        _sortOrder == _SortOrder.byCategory;

    return Column(
      children: [
        _buildFilterAndSortBar(context, l10n),
        if (_isSearchVisible) _buildSearchField(context, l10n),
        _buildCategoryBar(
          context,
          l10n,
          categories: sortedCategories,
          categoryCounts: categoryCounts,
        ),
        if (showFeatured)
          _FeaturedSection(
            catalog: _catalog!,
            l10n: l10n,
            onTap: (module, catalogId) =>
                _openViewer(context, module, heroTag: catalogId),
          ),
        Expanded(
          child: filteredEntries.isEmpty
              ? _EmptyState(
                  query: query,
                  l10n: l10n,
                  onClear: () {
                    _clearCatalogRefinements();
                  },
                )
              : _viewMode == CatalogViewMode.grid
                  ? _buildGridContent(context, groupedEntries, l10n)
                  : _buildListContent(context, groupedEntries, l10n),
        ),
      ],
    );
  }

  Widget _buildFilterAndSortBar(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    final dimensionBaseEntries = _entriesForDimensionCounts(l10n);
    final allCount = dimensionBaseEntries.length;
    final twoDCount = dimensionBaseEntries
        .where((entry) => entry.module.dimension == FractalDimension.twoD)
        .length;
    final threeDCount = dimensionBaseEntries
        .where((entry) => entry.module.dimension == FractalDimension.threeD)
        .length;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          // Dimension filters + Search — horizontally scrollable
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _DimChip(
                    chipKey: const Key('catalogDimensionChip_all'),
                    label: l10n.catalogFilterAll,
                    count: allCount,
                    selected: _dimensionFilter == _DimensionFilter.all,
                    onTap: () => _updateDimensionFilter(_DimensionFilter.all),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  _DimChip(
                    chipKey: const Key('catalogDimensionChip_2d'),
                    label: l10n.dimension2d,
                    count: twoDCount,
                    selected: _dimensionFilter == _DimensionFilter.twoD,
                    onTap: () => _updateDimensionFilter(_DimensionFilter.twoD),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  _DimChip(
                    chipKey: const Key('catalogDimensionChip_3d'),
                    label: l10n.dimension3d,
                    count: threeDCount,
                    selected: _dimensionFilter == _DimensionFilter.threeD,
                    onTap: () =>
                        _updateDimensionFilter(_DimensionFilter.threeD),
                  ),
                  const SizedBox(width: AppSpacing.md),
                ],
              ),
            ),
          ),
          // Action buttons on the right
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Search button
              _SimpleIconButton(
                icon: Icons.search_rounded,
                isActive: _isSearchVisible,
                onTap: _toggleSearch,
              ),
              const SizedBox(width: AppSpacing.xs),
              // View toggle button
              _SimpleIconButton(
                icon: _viewMode == CatalogViewMode.grid
                    ? Icons.view_list_rounded
                    : Icons.grid_view_rounded,
                onTap: () => setState(() {
                  _viewMode = _viewMode == CatalogViewMode.grid
                      ? CatalogViewMode.list
                      : CatalogViewMode.grid;
                }),
              ),
              const SizedBox(width: AppSpacing.xs),
              // Sort dropdown
              PopupMenuButton<_SortOrder>(
                tooltip: l10n.catalogFilterSortOrder,
                initialValue: _sortOrder,
                onSelected: (value) => setState(() => _sortOrder = value),
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: _SortOrder.byCategory,
                    child: Text(l10n.catalogSortByCategory),
                  ),
                  PopupMenuItem(
                    value: _SortOrder.alphabetical,
                    child: Text(l10n.catalogSortAlphabetical),
                  ),
                ],
                child: ConstrainedBox(
                  constraints:
                      const BoxConstraints(minHeight: 48, minWidth: 48),
                  child: Icon(
                    Icons.sort_rounded,
                    size: 22,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBar(
    BuildContext context,
    AppLocalizations l10n, {
    required List<String> categories,
    required Map<String, int> categoryCounts,
  }) {
    if (categories.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xs,
        AppSpacing.lg,
        AppSpacing.xs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.catalogFilterCategories,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          SizedBox(
            height: 52,
            child: ListView.separated(
              key: const Key('catalogCategoryScroll'),
              scrollDirection: Axis.horizontal,
              itemCount: categories.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.xs),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _DimChip(
                    chipKey: const Key('catalogCategoryChip_all'),
                    label: l10n.catalogFilterAll,
                    count: _entriesForCategoryCounts(l10n).length,
                    selected: _selectedCategory == null,
                    onTap: () {
                      setState(() {
                        _selectedCategory = null;
                      });
                    },
                  );
                }

                final category = categories[index - 1];
                return _DimChip(
                  chipKey: Key(
                    'catalogCategoryChip_${_keySegment(category)}',
                  ),
                  label: category,
                  count: categoryCounts[category] ?? 0,
                  selected: _selectedCategory == category,
                  onTap: () {
                    setState(() {
                      _selectedCategory =
                          _selectedCategory == category ? null : category;
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCatalogSummary(
    BuildContext context,
    AppLocalizations l10n, {
    required int resultCount,
    required int categoryCount,
  }) {
    final sortLabel = _sortOrder == _SortOrder.byCategory
        ? l10n.catalogSortByCategory
        : l10n.catalogSortAlphabeticalShort;
    final viewLabel = _viewMode == CatalogViewMode.grid
        ? l10n.catalogGridView
        : l10n.catalogListView;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xs,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(
            color: AppColors.border.withValues(alpha: 0.35),
          ),
        ),
        child: Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _SummaryPill(
              icon: Icons.auto_awesome_mosaic_rounded,
              label: l10n.catalogResults,
              value: '$resultCount',
            ),
            _SummaryPill(
              icon: Icons.category_rounded,
              label: l10n.catalogCategories,
              value: '$categoryCount',
            ),
            _SummaryPill(
              icon: _viewMode == CatalogViewMode.grid
                  ? Icons.grid_view_rounded
                  : Icons.view_list_rounded,
              label: viewLabel,
            ),
            _SummaryPill(
              icon: Icons.sort_rounded,
              label: sortLabel,
            ),
            if (_selectedCategory != null)
              _SummaryPill(
                icon: Icons.filter_alt_rounded,
                label: _selectedCategory!,
              ),
            if (_hasActiveCatalogRefinements)
              TextButton.icon(
                key: const Key('catalogClearFiltersButton'),
                onPressed: _clearCatalogRefinements,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(l10n.actionClearFilters),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField(BuildContext context, AppLocalizations l10n) {
    return Semantics(
      label: l10n.semanticSearchField,
      textField: true,
      child: AnimatedContainer(
        duration: AppAnimations.normal,
        curve: AppAnimations.defaultCurve,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          border: Border.all(
            color: _isSearchFocused
                ? AppColors.primary.withValues(alpha: 0.6)
                : AppColors.border.withValues(alpha: 0.3),
            width: _isSearchFocused ? 1.5 : 1,
          ),
          boxShadow: _isSearchFocused
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.15),
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
          style:
              AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
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
            setState(() {});
          },
        ),
      ),
    );
  }

  Widget _buildViewToggle(BuildContext context, AppLocalizations l10n) {
    final isGrid = _viewMode == CatalogViewMode.grid;
    return Semantics(
      button: true,
      label: isGrid ? l10n.catalogSwitchToList : l10n.catalogSwitchToGrid,
      child: Tooltip(
        message: isGrid ? l10n.catalogListView : l10n.catalogGridView,
        child: IconButton(
          key: const Key('catalogViewToggleButton'),
          tooltip: isGrid ? l10n.catalogListView : l10n.catalogGridView,
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
              onTap: () => _openViewer(context, item.entry!.module,
                  heroTag: item.entry!.catalogId),
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

    // Flatten sections into a single lazy list
    // Each section: [header_item, ...grid_items, spacer_item]
    final flatItems =
        <({String? type, String? title, int? count, CatalogEntry? entry})>[];
    for (final section in groupedEntries.entries) {
      flatItems.add((
        type: 'header',
        title: section.key,
        count: section.value.length,
        entry: null
      ));
      for (final entry in section.value) {
        flatItems.add((type: 'tile', title: null, count: null, entry: entry));
      }
      flatItems.add((type: 'spacer', title: null, count: null, entry: null));
    }

    return ListView.builder(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.sm,
        bottom: MediaQuery.of(context).padding.bottom + 100,
      ),
      cacheExtent: 500, // Pre-render items outside viewport
      itemCount: flatItems.length,
      itemExtent: 200, // Approximate height per item (grid tiles + header)
      itemBuilder: (context, index) {
        final item = flatItems[index];
        switch (item.type) {
          case 'header':
            return _SectionHeader(title: item.title!, count: item.count!);
          case 'tile':
            return RepaintBoundary(
              child: _ModuleGridTile(
                entry: item.entry!,
                l10n: l10n,
                shimmerController: _shimmerController,
                onTap: () => _openViewer(context, item.entry!.module,
                    heroTag: item.entry!.catalogId),
              ),
            );
          case 'spacer':
            return const SizedBox(height: AppSpacing.md);
          default:
            return const SizedBox.shrink();
        }
      },
    );
  }

  void _openViewer(BuildContext context, FractalModule module,
      {String? heroTag}) {
    final controller = context.read<FractalController>();
    controller.selectModule(module);
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => MultiProvider(
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
        transitionDuration:
            heroTag != null ? AppAnimations.slow : AppAnimations.normal,
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
    final l10n = AppLocalizations.of(context)!;
    return Semantics(
      header: true,
      label: l10n.semanticSectionHeader(title, count),
      child: Padding(
        padding: const EdgeInsets.only(
          top: AppSpacing.md,
          bottom: AppSpacing.sm,
        ),
        child: Row(
          children: [
            // Colored left accent border
            ExcludeSemantics(
              child: Container(
                width: 3,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
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
            // Count badge (decorative — count is already in the Semantics label)
            ExcludeSemantics(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
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
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Simple icon button
// ---------------------------------------------------------------------------

class _SimpleIconButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _SimpleIconButton({
    required this.icon,
    this.isActive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isActive,
      label: 'Button',
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppAnimations.fast,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primary.withValues(alpha: 0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 22,
            color: isActive ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Dimension filter chip
// ---------------------------------------------------------------------------

class _DimChip extends StatelessWidget {
  final Key? chipKey;
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  const _DimChip({
    this.chipKey,
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: selected
          ? '$label filter, selected, $count fractals'
          : '$label filter, $count fractals',
      child: GestureDetector(
        key: chipKey,
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppAnimations.fast,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.18)
                : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? AppColors.primary.withValues(alpha: 0.5)
                  : AppColors.border.withValues(alpha: 0.3),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(
                  color: selected ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
              const SizedBox(width: 5),
              AnimatedContainer(
                duration: AppAnimations.fast,
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primary.withValues(alpha: 0.28)
                      : AppColors.border.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$count',
                  style: AppTypography.labelSmall.copyWith(
                    color: selected ? AppColors.primary : AppColors.textMuted,
                    fontWeight: FontWeight.w700,
                    fontSize: 9,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;

  const _SummaryPill({
    required this.icon,
    required this.label,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: AppColors.textMuted,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (value != null) ...[
            const SizedBox(width: 6),
            Text(
              value!,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Grid tile with elevation, gradient overlay, and better text readability
// ---------------------------------------------------------------------------

class _ModuleGridTile extends StatefulWidget {
  final CatalogEntry entry;
  final AppLocalizations l10n;
  final VoidCallback onTap;
  final _GlobalShimmerController? shimmerController;

  const _ModuleGridTile({
    required this.entry,
    required this.l10n,
    required this.onTap,
    this.shimmerController,
  });

  @override
  State<_ModuleGridTile> createState() => _ModuleGridTileState();
}

class _ModuleGridTileState extends State<_ModuleGridTile>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  bool _isPressed = false;
  late final AnimationController _glowController;
  late final Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: AppAnimations.fast,
    );
    _glowAnim = CurvedAnimation(
      parent: _glowController,
      curve: AppAnimations.snappyCurve,
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  void _setHighlight(bool on) {
    setState(() {
      _isHovered = on;
    });
    if (on) {
      _glowController.forward();
    } else {
      _glowController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final is3D = widget.entry.module.dimension == FractalDimension.threeD;
    final dimensionLabel =
        is3D ? widget.l10n.dimension3d : widget.l10n.dimension2d;
    final name = widget.entry.module.displayName(widget.l10n);
    final accentColor = _categoryAccentColor(widget.entry.category);

    return Semantics(
      label: widget.l10n.semanticFractalCard(name, dimensionLabel),
      button: true,
      child: MouseRegion(
        onEnter: (_) => _setHighlight(true),
        onExit: (_) => _setHighlight(false),
        child: GestureDetector(
          key: Key('catalogModuleCard_${widget.entry.catalogId}'),
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: widget.onTap,
          child: AnimatedBuilder(
            animation: _glowAnim,
            builder: (context, child) {
              final glow = _glowAnim.value;
              return AnimatedContainer(
                duration: AppAnimations.fast,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.22),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                    if (_isHovered || _isPressed)
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.35 * glow),
                        blurRadius: 16,
                        spreadRadius: 1,
                        offset: Offset.zero,
                      ),
                  ],
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(AppSpacing.cardRadius),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Thumbnail
                          _PreviewThumbnail(
                            catalogId: widget.entry.catalogId,
                            is3D: is3D,
                            category: widget.entry.category,
                            shimmerController: widget.shimmerController,
                          ),
                          // Gradient overlay for text
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(6, 20, 6, 7),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.78),
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
                                  shadows: const [
                                    Shadow(
                                      color: Colors.black54,
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Press darkening overlay
                          if (_isPressed)
                            Positioned.fill(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.15),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Animated shimmer border overlay on hover/press
                    if (_isHovered || _isPressed)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: AnimatedOpacity(
                            opacity: glow,
                            duration: AppAnimations.fast,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    AppSpacing.cardRadius),
                                border: Border.all(
                                  color: accentColor.withValues(alpha: 0.75),
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
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
                  color: AppColors.surfaceVariant.withValues(alpha: 0.5),
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
// Featured hero carousel
// ---------------------------------------------------------------------------

class _FeaturedSection extends StatelessWidget {
  final CatalogRepository catalog;
  final AppLocalizations l10n;
  final void Function(FractalModule, String catalogId) onTap;

  const _FeaturedSection({
    required this.catalog,
    required this.l10n,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Resolve featured entries from the catalog, preserving order.
    final featured = _kFeaturedFractalIds
        .map((id) {
          try {
            return catalog.entries.firstWhere(
              (e) => e.catalogId == id || e.catalogId == 'core.$id',
            );
          } catch (_) {
            return null;
          }
        })
        .whereType<CatalogEntry>()
        .toList();

    if (featured.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          label: l10n.semanticFeaturedSection,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: Row(
              children: [
                ExcludeSemantics(
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.45),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      size: 11,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  l10n.catalogFeatured,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.6,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: MediaQuery.textScalerOf(context).scale(1) > 2.0 ? 140 : 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: featured.length,
            itemBuilder: (context, index) {
              final entry = featured[index];
              return Padding(
                padding: EdgeInsets.only(
                  right: index < featured.length - 1 ? AppSpacing.sm : 0,
                ),
                child: _FeaturedCard(
                  entry: entry,
                  l10n: l10n,
                  onTap: () => onTap(entry.module, entry.catalogId),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.border.withValues(alpha: 0.6),
                  AppColors.border.withValues(alpha: 0.6),
                  Colors.transparent,
                ],
                stops: const [0, 0.15, 0.85, 1],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
      ],
    );
  }
}

class _FeaturedCard extends StatefulWidget {
  final CatalogEntry entry;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  const _FeaturedCard({
    required this.entry,
    required this.l10n,
    required this.onTap,
  });

  @override
  State<_FeaturedCard> createState() => _FeaturedCardState();
}

class _FeaturedCardState extends State<_FeaturedCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  bool _isPressed = false;
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: AppAnimations.fast,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(
          parent: _scaleController, curve: AppAnimations.snappyCurve),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _setHover(bool on) {
    setState(() => _isHovered = on);
    if (on) {
      _scaleController.forward();
    } else {
      _scaleController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final is3D = widget.entry.module.dimension == FractalDimension.threeD;
    final name = widget.entry.module.displayName(widget.l10n);
    final accentColor = _categoryAccentColor(widget.entry.category);

    final is3DLabel = widget.entry.module.dimension == FractalDimension.threeD
        ? widget.l10n.dimension3d
        : widget.l10n.dimension2d;
    final featuredName = widget.entry.module.displayName(widget.l10n);

    return Semantics(
      label: widget.l10n.semanticFractalCard(featuredName, is3DLabel),
      button: true,
      child: MouseRegion(
        onEnter: (_) => _setHover(true),
        onExit: (_) => _setHover(false),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: widget.onTap,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: AnimatedContainer(
              duration: AppAnimations.fast,
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                  if (_isHovered || _isPressed)
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.45),
                      blurRadius: 20,
                      spreadRadius: 1,
                    ),
                ],
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        _PreviewThumbnail(
                          catalogId: widget.entry.catalogId,
                          is3D: is3D,
                          category: widget.entry.category,
                        ),
                        // Deep bottom gradient for name legibility
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          height: 90,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.85),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Name label
                        Positioned(
                          left: 8,
                          right: 8,
                          bottom: 8,
                          child: Text(
                            name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: AppTypography.labelSmall.copyWith(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              shadows: const [
                                Shadow(color: Colors.black87, blurRadius: 6),
                              ],
                            ),
                          ),
                        ),
                        // Top accent gradient strip
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 3,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(AppSpacing.cardRadius),
                                topRight:
                                    Radius.circular(AppSpacing.cardRadius),
                              ),
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primary.withValues(alpha: 0.9),
                                  accentColor.withValues(alpha: 0.9),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // 3D badge
                        if (is3D)
                          Positioned(
                            top: 10,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.warning.withValues(alpha: 0.92),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppColors.warning,
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.25),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: Text(
                                '3D',
                                style: AppTypography.labelSmall.copyWith(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 10,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ),
                        // Press overlay
                        if (_isPressed)
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.18),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Glow border on hover / press
                  if (_isHovered || _isPressed)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(AppSpacing.cardRadius),
                            border: Border.all(
                              color: accentColor.withValues(alpha: 0.8),
                              width: 1.5,
                            ),
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
    final semanticLabel = widget.l10n.semanticFractalCard(name, dimensionLabel);

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
              ? AppColors.primary.withValues(alpha: 0.4)
              : AppColors.border.withValues(alpha: 0.4),
        ),
        boxShadow: _isPressed
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.1),
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$dimensionLabel / ${widget.entry.category}',
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
                    ? AppColors.primary.withValues(alpha: 0.2)
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

String _keySegment(String value) {
  return value
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_+|_+$'), '');
}

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
  final _GlobalShimmerController? shimmerController;

  const _PreviewThumbnail({
    required this.catalogId,
    required this.is3D,
    required this.category,
    this.size,
    this.shimmerController,
  });

  @override
  State<_PreviewThumbnail> createState() => _PreviewThumbnailState();
}

class _PreviewThumbnailState extends State<_PreviewThumbnail>
    with SingleTickerProviderStateMixin {
  late final AnimationController _localShimmerController;
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
    // Use global controller if available, otherwise local fallback
    if (widget.shimmerController != null) {
      _localShimmerController = widget.shimmerController!.controller;
    } else {
      _localShimmerController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1200),
      );
      if (!RuntimeModeService.isAutomatedTest) {
        _localShimmerController.repeat();
      }
    }
  }

  @override
  void dispose() {
    // Only dispose local controller, not the global one
    if (widget.shimmerController == null) {
      _localShimmerController.dispose();
    }
    super.dispose();
  }

  void _markImageLoaded() {
    if (_imageLoaded) return;
    if (!mounted) return;
    setState(() => _imageLoaded = true);
  }

  void _markImageError() {
    if (_imageError) return;
    if (!mounted) return;
    setState(() => _imageError = true);
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
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Shimmer shown while image is loading
          if (!_imageLoaded && !_imageError)
            _ShimmerSkeleton(controller: _localShimmerController),

          // Image (or gradient fallback on error)
          Positioned.fill(
            child: Image(
              image: ResizeImage(
                AssetImage(thumbAsset),
                width: 256,
                height: 256,
              ),
              fit: BoxFit.cover,
              filterQuality: FilterQuality.medium,
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                final imageReady = wasSynchronouslyLoaded || frame != null;
                if (imageReady && !_imageLoaded) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _markImageLoaded();
                  });
                }
                return AnimatedOpacity(
                  opacity: imageReady ? 1.0 : 0.0,
                  duration: imageReady
                      ? Duration.zero
                      : const Duration(milliseconds: 250),
                  child: child,
                );
              },
              errorBuilder: (context, error, stack) {
                if (!_imageError) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _markImageError();
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
                color: accentColor.withValues(alpha: 0.85),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
            ),
          ),

          // Dimension badge — pill shape, amber for 3D, subtle for 2D.
          // ExcludeSemantics: the parent card widget already announces the
          // dimension in its semanticFractalCard label.
          Positioned(
            top: 7,
            right: 6,
            child: ExcludeSemantics(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: widget.is3D
                      ? AppColors.warning.withValues(alpha: 0.92)
                      : Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: widget.is3D
                        ? AppColors.warning
                        : Colors.white.withValues(alpha: 0.45),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
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
          ),

          // "Preview approximate" label
          if (isApproximate)
            Positioned(
              bottom: 4,
              left: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
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
        final col = ((hash ~/ math.pow(3, i).toInt()) % cols).toDouble() * step;
        final row = ((hash ~/ math.pow(5, i).toInt()) % rows).toDouble() * step;
        canvas.drawRect(
            Rect.fromLTWH(col, row, step - 1, step - 1), accentPaint);
      }
    }
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
            colorMid.withValues(alpha: 0.55),
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
            colorB.withValues(alpha: 0.4),
            Colors.transparent,
            colorA.withValues(alpha: 0.3),
          ],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_FractalGradientPainter old) =>
      old.catalogId != catalogId || old.category != category;
}

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/services/platform/accessibility_service.dart';
import 'package:flutter_fractals/core/services/platform/runtime_mode_service.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/features/catalog/data/catalog_entry.dart';
import 'package:flutter_fractals/features/catalog/data/catalog_family.dart';
import 'package:flutter_fractals/features/catalog/data/catalog_filter.dart';
import 'package:flutter_fractals/features/catalog/data/catalog_repository.dart';
import 'package:flutter_fractals/features/catalog/data/catalog_search_debouncer.dart';
import 'package:flutter_fractals/features/catalog/data/catalog_thumbnail_plan.dart';
import 'package:flutter_fractals/core/widgets/animated_widgets.dart';
import 'package:flutter_fractals/features/renderer/widgets/renderer/fractal_renderer.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/features/viewer/fractal_viewer_screen.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_fractals/shared/utils/slugify.dart';

part 'widgets/catalog_widgets.dart';

enum CatalogViewMode { grid, list }

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
    if (!RuntimeModeService.isAutomatedTest) {
      controller.repeat();
    }
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
  static const _defaultCategory = 'Escape-Time';
  static const _categorySwipeVelocity = 350.0;

  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  bool get _isSearchFocused => _focusNode.hasFocus;
  bool _isSearchVisible = false;
  CatalogViewMode _viewMode = CatalogViewMode.grid;
  String? _selectedCategory = _defaultCategory;

  // Search debounce - prevents rebuild on every keystroke
  final CatalogSearchDebouncer _searchDebouncer = CatalogSearchDebouncer();
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
    _focusNode.addListener(_onSearchFocusChanged);
    _loadViewPreference();
  }

  void _onSearchChanged() {
    _searchDebouncer.schedule(() {
      if (!mounted) return;
      final nextQuery = _searchController.text;
      if (nextQuery == _debouncedQuery) return;
      setState(() => _debouncedQuery = nextQuery);
    });
  }

  void _resetSearchInputState() {
    _searchController.clear();
    _searchDebouncer.cancel();
    _debouncedQuery = '';
    _focusNode.unfocus();
  }

  void _clearSearchInput() {
    setState(_resetSearchInputState);
  }

  void _onSearchFocusChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _searchDebouncer.dispose();
    _searchController.removeListener(_onSearchChanged);
    _focusNode.removeListener(_onSearchFocusChanged);
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
    _catalog = CatalogRepository.fromRegistry(registry);
  }

  Future<void> _loadViewPreference() async {
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
    final isGrid = prefs.getBool(_viewPrefKey) ?? true;
    if (!mounted) return;
    setState(() {
      _viewMode = isGrid ? CatalogViewMode.grid : CatalogViewMode.list;
    });
  }

  Future<void> _setViewMode(CatalogViewMode mode) async {
    setState(() => _viewMode = mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_viewPrefKey, mode == CatalogViewMode.grid);
  }

  CatalogFilterCriteria get _currentFilterCriteria => CatalogFilterCriteria(
        query: _debouncedQuery,
        selectedCategory: _selectedCategory,
      );

  void _toggleSearch() {
    setState(() {
      _isSearchVisible = !_isSearchVisible;
      if (!_isSearchVisible) {
        _resetSearchInputState();
      } else {
        // Auto focus the search field
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _focusNode.requestFocus();
        });
      }
    });
  }

  void _clearCatalogRefinements() {
    setState(() {
      _resetSearchInputState();
      _isSearchVisible = false;
      _selectedCategory = _defaultCategory;
    });
  }

  /// True when a search query or category filter is narrowing the catalog —
  /// used to surface the result count + one-tap "clear all".
  bool get _hasActiveRefinements =>
      _debouncedQuery.isNotEmpty || _selectedCategory != _defaultCategory;

  Map<String, List<CatalogEntry>> _groupAndSort(
      List<CatalogEntry> entries, AppLocalizations l10n) {
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
    final filterCriteria = _currentFilterCriteria;
    final filterResult = CatalogFilter.apply(
      entries: _catalog!.entries,
      criteria: filterCriteria,
      l10n: l10n,
    );
    final query = filterCriteria.searchQuery.value;
    final filteredEntries = filterResult.filteredEntries;
    final groupedEntries = _groupAndSort(filteredEntries, l10n);
    return GestureDetector(
      key: const Key('catalogCategorySwipeArea'),
      behavior: HitTestBehavior.opaque,
      onHorizontalDragEnd: (details) => _handleCategorySwipe(
        details,
        filterResult,
      ),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _buildCatalogHeader(
              l10n,
              resultCount: filteredEntries.length,
            ),
          ),
          SliverPersistentHeader(
            key: const Key('catalogPinnedFilterBar'),
            pinned: true,
            delegate: _PinnedHeaderDelegate(
              height: _hasActiveRefinements ? 112 : 80,
              child: _buildPinnedTopBar(
                context,
                l10n,
                filterResult,
                filteredEntries.length,
              ),
            ),
          ),
          if (filteredEntries.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _EmptyState(
                query: query,
                l10n: l10n,
                onClear: _clearCatalogRefinements,
              ),
            )
          else if (_viewMode == CatalogViewMode.grid)
            _buildGridContentSliver(groupedEntries, l10n)
          else
            _buildListContentSliver(groupedEntries, l10n),
        ],
      ),
    );
  }

  void _handleCategorySwipe(
    DragEndDetails details,
    CatalogFilterResult filterResult,
  ) {
    if (_isSearchVisible) return;
    final velocity = details.primaryVelocity ?? 0;
    if (velocity.abs() < _categorySwipeVelocity) return;
    _selectRelativeCategory(filterResult, velocity < 0 ? 1 : -1);
  }

  void _selectRelativeCategory(CatalogFilterResult filterResult, int offset) {
    final choices = _categoryChoices(filterResult);
    if (choices.length < 2) return;
    final currentIndex = choices.indexOf(_selectedCategory);
    final index = currentIndex < 0 ? 0 : currentIndex;
    final nextIndex = math.max(0, math.min(choices.length - 1, index + offset));
    final nextCategory = choices[nextIndex];
    if (nextCategory == _selectedCategory) return;
    setState(() => _selectedCategory = nextCategory);
    AccessibilityService.announce(nextCategory ?? _allCategoriesLabel(context));
  }

  bool _hasRelativeCategory(CatalogFilterResult filterResult, int offset) {
    final choices = _categoryChoices(filterResult);
    if (choices.length < 2) return false;
    final currentIndex = choices.indexOf(_selectedCategory);
    final index = currentIndex < 0 ? 0 : currentIndex;
    final nextIndex = math.max(0, math.min(choices.length - 1, index + offset));
    return choices[nextIndex] != _selectedCategory;
  }

  List<String?> _categoryChoices(CatalogFilterResult filterResult) {
    final counts = filterResult.categoryCounts;
    final categories = counts.keys.toList()
      ..sort((a, b) {
        final countCompare = (counts[b] ?? 0).compareTo(counts[a] ?? 0);
        if (countCompare != 0) return countCompare;
        return a.compareTo(b);
      });
    return [null, ...categories];
  }

  String _previousCategoryLabel(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'es'
        ? 'Categoría anterior'
        : 'Previous category';
  }

  String _nextCategoryLabel(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'es'
        ? 'Categoría siguiente'
        : 'Next category';
  }

  Widget _buildCatalogHeader(
    AppLocalizations l10n, {
    required int resultCount,
  }) {
    final title = _selectedCategory ?? l10n.catalogAllFractals;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.xs,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withValues(alpha: 0.22),
              AppColors.surfaceElevated.withValues(alpha: 0.92),
              AppColors.secondary.withValues(alpha: 0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.glassBorder),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.catalogTitle.toUpperCase(),
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.secondaryLight,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.4,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.titleLarge.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.catalogResultsCount(resultCount),
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            ExcludeSemantics(
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.secondaryLight,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPinnedTopBar(
    BuildContext context,
    AppLocalizations l10n,
    CatalogFilterResult filterResult,
    int resultCount,
  ) {
    return ColoredBox(
      color: AppColors.background,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildFilterAndSortBar(context, l10n, filterResult),
          if (_hasActiveRefinements)
            _buildActiveFilterChips(context, l10n, resultCount),
        ],
      ),
    );
  }

  Widget _buildFilterAndSortBar(
    BuildContext context,
    AppLocalizations l10n,
    CatalogFilterResult filterResult,
  ) {
    final categories = filterResult.sortedCategories;
    final categoryCounts = filterResult.categoryCounts;
    final totalCategoryCount = filterResult.categoryBaseEntries.length;
    final allCategoriesLabel = _allCategoriesLabel(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.78),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.45)),
        ),
        child: Row(
          children: [
            Expanded(
              child: _isSearchVisible
                  ? _buildCompactSearchField(context, l10n)
                  : Row(
                      children: [
                        _CategoryStepButton(
                          buttonKey: const Key('catalogPreviousCategoryButton'),
                          icon: Icons.chevron_left_rounded,
                          semanticLabel: _previousCategoryLabel(context),
                          enabled: _hasRelativeCategory(filterResult, -1),
                          onTap: () =>
                              _selectRelativeCategory(filterResult, -1),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: _CategoryFilterRail(
                            allCategoriesLabel: allCategoriesLabel,
                            totalCategoryCount: totalCategoryCount,
                            categories: categories,
                            categoryCounts: categoryCounts,
                            selectedCategory: _selectedCategory,
                            onSelect: (category) {
                              setState(() {
                                _selectedCategory =
                                    category == _selectedCategory
                                        ? null
                                        : category;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        _CategoryStepButton(
                          buttonKey: const Key('catalogNextCategoryButton'),
                          icon: Icons.chevron_right_rounded,
                          semanticLabel: _nextCategoryLabel(context),
                          enabled: _hasRelativeCategory(filterResult, 1),
                          onTap: () => _selectRelativeCategory(filterResult, 1),
                        ),
                      ],
                    ),
            ),
            const SizedBox(width: AppSpacing.xs),
            _SimpleIconButton(
              buttonKey: const Key('catalogSearchToggleButton'),
              icon: Icons.search_rounded,
              semanticLabel: l10n.catalogSearchHint,
              isActive: _isSearchVisible,
              onTap: _toggleSearch,
            ),
            const SizedBox(width: AppSpacing.xs),
            _SimpleIconButton(
              buttonKey: const Key('catalogViewToggleButton'),
              icon: _viewMode == CatalogViewMode.grid
                  ? Icons.view_list_rounded
                  : Icons.grid_view_rounded,
              semanticLabel: _viewMode == CatalogViewMode.grid
                  ? l10n.catalogSwitchToList
                  : l10n.catalogSwitchToGrid,
              onTap: () => _setViewMode(
                _viewMode == CatalogViewMode.grid
                    ? CatalogViewMode.list
                    : CatalogViewMode.grid,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactSearchField(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return Semantics(
      label: l10n.semanticSearchField,
      textField: true,
      child: TextField(
        key: const Key('catalogSearchField'),
        controller: _searchController,
        focusNode: _focusNode,
        style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: AppColors.surfaceVariant,
          hintText: l10n.catalogSearchHint,
          hintStyle:
              AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: _isSearchFocused ? AppColors.primary : AppColors.textMuted,
          ),
          suffixIcon: _searchController.text.isEmpty
              ? null
              : IconButton(
                  key: const ValueKey('clear'),
                  tooltip:
                      MaterialLocalizations.of(context).deleteButtonTooltip,
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: _clearSearchInput,
                ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
            borderSide: BorderSide(
              color: AppColors.border.withValues(alpha: 0.3),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
            borderSide: BorderSide(
              color: AppColors.border.withValues(alpha: 0.3),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
            borderSide: BorderSide(
              color: AppColors.primary.withValues(alpha: 0.6),
              width: 1.5,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  /// Slim summary row shown only while a filter is active: result count on the
  /// left, removable chips on the right so users can unwind one refinement.
  String _allCategoriesLabel(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'es'
        ? 'Todas las categorías'
        : 'All categories';
  }

  Widget _buildActiveFilterChips(
    BuildContext context,
    AppLocalizations l10n,
    int resultCount,
  ) {
    final selectedCategory = _selectedCategory;
    final chips = <Widget>[
      Text(
        l10n.catalogResultsCount(resultCount),
        style: AppTypography.labelSmall.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    ];

    if (_debouncedQuery.isNotEmpty) {
      chips.add(
        InputChip(
          key: const Key('catalogActiveSearchChip'),
          label: Text('Search: $_debouncedQuery'),
          onDeleted: _clearSearchInput,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
      );
    }

    if (selectedCategory != _defaultCategory) {
      chips.add(
        InputChip(
          key: const Key('catalogActiveCategoryChip'),
          label: Text(selectedCategory ?? _allCategoriesLabel(context)),
          onDeleted: () => setState(() => _selectedCategory = _defaultCategory),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
      );
    }

    chips.add(
      ActionChip(
        key: const Key('catalogClearFiltersButton'),
        avatar: const Icon(Icons.clear_all_rounded, size: 16),
        label: Text(l10n.catalogClearFilters),
        onPressed: _clearCatalogRefinements,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
    );

    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, 4),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) => Center(child: chips[index]),
        separatorBuilder: (context, index) =>
            const SizedBox(width: AppSpacing.xs),
        itemCount: chips.length,
      ),
    );
  }

  Widget _buildListContentSliver(
    Map<String, List<CatalogEntry>> groupedEntries,
    AppLocalizations l10n,
  ) {
    // Flatten grouped entries into a flat list where each item is either
    // a section header, a card, or spacing.
    final flatItems = <_ListItem>[];
    for (final section in groupedEntries.entries) {
      flatItems.add(_ListItem.header(section.key, section.value.length));
      for (final entry in section.value) {
        flatItems.add(_ListItem.card(entry));
      }
      flatItems.add(_ListItem.spacing());
    }
    // Bottom padding
    flatItems.add(_ListItem.spacing());

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final item = flatItems[index];
          if (item.isHeader) {
            return Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                top: AppSpacing.md,
              ),
              child: _SectionHeader(title: item.title!, count: item.count!),
            );
          } else if (item.isSpacing) {
            return const SizedBox(height: AppSpacing.lg);
          } else {
            final entry = item.entry!;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: RepaintBoundary(
                child: _ModuleCard(
                  entry: entry,
                  onTap: () => _openViewer(
                    context,
                    entry.module,
                    heroTag: entry.catalogId,
                    catalogFamily: entry.family,
                  ),
                  l10n: l10n,
                  shimmerController: _shimmerController,
                ),
              ),
            );
          }
        },
        childCount: flatItems.length,
      ),
    );
  }

  Widget _buildGridContentSliver(
    Map<String, List<CatalogEntry>> groupedEntries,
    AppLocalizations l10n,
  ) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width >= 1024
        ? 5
        : width >= 840
            ? 4
            : width >= 600
                ? 3
                : 2;
    final children = <Widget>[];

    for (final section in groupedEntries.entries) {
      children.add(
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              top: AppSpacing.md,
            ),
            child:
                _SectionHeader(title: section.key, count: section.value.length),
          ),
        ),
      );
      children.add(
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final entry = section.value[index];
                return RepaintBoundary(
                  child: _ModuleGridTile(
                    entry: entry,
                    l10n: l10n,
                    shimmerController: _shimmerController,
                    onTap: () => _openViewer(
                      context,
                      entry.module,
                      heroTag: entry.catalogId,
                      catalogFamily: entry.family,
                    ),
                  ),
                );
              },
              childCount: section.value.length,
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: AppSpacing.md,
              crossAxisSpacing: AppSpacing.md,
              childAspectRatio: 1 / 0.82,
            ),
          ),
        ),
      );
      children.add(
        const SliverToBoxAdapter(
          child: SizedBox(height: AppSpacing.md),
        ),
      );
    }

    // Add bottom padding
    children.add(
      SliverToBoxAdapter(
        child: SizedBox(height: MediaQuery.of(context).padding.bottom + 100),
      ),
    );

    return SliverMainAxisGroup(slivers: children);
  }

  void _openViewer(
    BuildContext context,
    FractalModule module, {
    String? heroTag,
    CatalogFamily catalogFamily = CatalogFamily.core,
  }) {
    final controller = context.read<FractalController>();
    controller.selectModule(module, resetView: true);
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: controller),
          ],
          child: FractalViewerScreen(catalogFamily: catalogFamily),
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
// Flat list item type for lazy list view rendering
// ---------------------------------------------------------------------------

enum _ListItemType { header, card, spacing }

class _ListItem {
  final _ListItemType type;
  final CatalogEntry? entry;
  final String? title;
  final int? count;

  const _ListItem._({required this.type, this.entry, this.title, this.count});

  factory _ListItem.header(String title, int count) =>
      _ListItem._(type: _ListItemType.header, title: title, count: count);

  factory _ListItem.card(CatalogEntry entry) =>
      _ListItem._(type: _ListItemType.card, entry: entry);

  factory _ListItem.spacing() => _ListItem._(type: _ListItemType.spacing);

  bool get isHeader => type == _ListItemType.header;
  bool get isSpacing => type == _ListItemType.spacing;
}

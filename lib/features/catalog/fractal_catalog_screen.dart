import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/rendering.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/shared/widgets/fractal_math_summary.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/services/platform/accessibility_service.dart';
import 'package:flutter_fractals/core/services/platform/runtime_mode_service.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/features/catalog/data/catalog_entry.dart';
import 'package:flutter_fractals/features/catalog/data/catalog_family.dart';
import 'package:flutter_fractals/features/catalog/data/catalog_filter.dart';
import 'package:flutter_fractals/features/catalog/data/catalog_repository.dart';
import 'package:flutter_fractals/features/catalog/data/catalog_search_debouncer.dart';
import 'package:flutter_fractals/features/catalog/data/catalog_thumbnail_cache.dart';
import 'package:flutter_fractals/features/catalog/data/catalog_thumbnail_render_gate.dart';
import 'package:flutter_fractals/features/catalog/data/catalog_thumbnail_telemetry.dart';
import 'package:flutter_fractals/features/catalog/data/catalog_thumbnail_plan.dart';
import 'package:flutter_fractals/core/widgets/animated_widgets.dart';
import 'package:flutter_fractals/features/renderer/widgets/renderer/fractal_renderer.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/features/viewer/fractal_viewer_screen.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_fractals/shared/utils/slugify.dart';

part 'widgets/catalog_widgets.dart';

enum CatalogViewMode { grid, list, miniatures }

class CatalogToolbarController extends ChangeNotifier {
  bool isSearchVisible = false;
  CatalogViewMode viewMode = CatalogViewMode.grid;
  VoidCallback? _toggleSearch;
  VoidCallback? _toggleViewMode;

  void attach({
    required VoidCallback toggleSearch,
    required VoidCallback toggleViewMode,
    required bool isSearchVisible,
    required CatalogViewMode viewMode,
  }) {
    _toggleSearch = toggleSearch;
    _toggleViewMode = toggleViewMode;
    this.isSearchVisible = isSearchVisible;
    this.viewMode = viewMode;
  }

  void detach() {
    _toggleSearch = null;
    _toggleViewMode = null;
  }

  void update({
    required bool isSearchVisible,
    required CatalogViewMode viewMode,
  }) {
    if (this.isSearchVisible == isSearchVisible && this.viewMode == viewMode) {
      return;
    }
    this.isSearchVisible = isSearchVisible;
    this.viewMode = viewMode;
    notifyListeners();
  }

  void toggleSearch() => _toggleSearch?.call();
  void toggleViewMode() => _toggleViewMode?.call();
}

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
  final CatalogToolbarController? toolbarController;
  final Future<CatalogViewMode> Function()? viewModeLoader;

  const FractalCatalogScreen({
    Key? key,
    this.toolbarController,
    this.viewModeLoader,
  }) : super(key: key);

  @override
  State<FractalCatalogScreen> createState() => _FractalCatalogScreenState();
}

class _FractalCatalogScreenState extends State<FractalCatalogScreen>
    with TickerProviderStateMixin {
  static const _viewPrefKey = 'catalog_view_grid';
  static const _viewModePrefKey = 'catalog_view_mode';
  static const _queryPrefKey = 'catalog_browse_query';
  static const _categoryPrefKey = 'catalog_browse_category';
  static const _collectionPrefKey = 'catalog_browse_collection';
  static const _dimensionPrefKey = 'catalog_browse_dimension';
  static const _scrollOffsetPrefKey = 'catalog_browse_scroll_offset';
  static const _favoritesPrefKey = 'catalog_favorite_ids';
  static const _recentPrefKey = 'catalog_recent_ids';
  static const _favoritesCategory = '@favorites';
  static const _recentCategory = '@recent';
  static const _categorySwipeVelocity = 350.0;

  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  final _scrollController = ScrollController();
  Timer? _scrollSaveDebounce;
  int _browseStateRevision = 0;
  bool get _isSearchFocused => _focusNode.hasFocus;
  bool _isSearchVisible = false;
  CatalogViewMode _viewMode = CatalogViewMode.grid;
  int _viewModeRevision = 0;
  String? _selectedCategory;
  String? _selectedCollection;
  CatalogDimensionFilter _dimensionFilter = CatalogDimensionFilter.all;
  final Set<String> _favoriteCatalogIds = <String>{};
  final List<String> _recentCatalogIds = <String>[];
  final Set<String> _collapsedCategories = <String>{};

  // Search debounce - prevents rebuild on every keystroke
  final CatalogSearchDebouncer _searchDebouncer = CatalogSearchDebouncer();
  String _debouncedQuery = '';

  // Cached catalog — rebuilt only when registry changes.
  CatalogRepository? _catalog;
  ModuleRegistry? _catalogRegistry;

  // Global shimmer controller
  late final _GlobalShimmerController _shimmerController;

  @override
  void initState() {
    super.initState();
    _PreviewThumbnail.beginCatalogSession();
    _shimmerController = _GlobalShimmerController.of(this);
    _searchController.addListener(_onSearchChanged);
    _focusNode.addListener(_onSearchFocusChanged);
    _scrollController.addListener(_onCatalogScrolled);
    _attachToolbarController();
    _loadViewPreference();
    _loadBrowsingState();
  }

  @override
  void didUpdateWidget(covariant FractalCatalogScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.toolbarController == widget.toolbarController) return;
    oldWidget.toolbarController?.detach();
    _attachToolbarController();
  }

  void _attachToolbarController() {
    widget.toolbarController?.attach(
      toggleSearch: _toggleSearch,
      toggleViewMode: _toggleViewMode,
      isSearchVisible: _isSearchVisible,
      viewMode: _viewMode,
    );
  }

  void _publishToolbarState() {
    widget.toolbarController?.update(
      isSearchVisible: _isSearchVisible,
      viewMode: _viewMode,
    );
  }

  Future<void> _loadBrowsingState() async {
    final revision = _browseStateRevision;
    final prefs = await SharedPreferences.getInstance();
    final query = prefs.getString(_queryPrefKey) ?? '';
    final storedCategory = prefs.getString(_categoryPrefKey);
    final collection = prefs.getString(_collectionPrefKey) ??
        (storedCategory == _favoritesCategory ||
                storedCategory == _recentCategory
            ? storedCategory
            : null);
    final category = _normalizeCategory(storedCategory);
    final dimensionIndex = prefs.getInt(_dimensionPrefKey) ?? 0;
    final dimension = dimensionIndex >= 0 &&
            dimensionIndex < CatalogDimensionFilter.values.length
        ? CatalogDimensionFilter.values[dimensionIndex]
        : CatalogDimensionFilter.all;
    final favorites =
        prefs.getStringList(_favoritesPrefKey) ?? const <String>[];
    final recent = prefs.getStringList(_recentPrefKey) ?? const <String>[];
    final offset = prefs.getDouble(_scrollOffsetPrefKey) ?? 0.0;
    if (!mounted || revision != _browseStateRevision) return;
    setState(() {
      _debouncedQuery = query;
      _searchController.text = query;
      _selectedCategory = category;
      _selectedCollection =
          collection == _favoritesCategory || collection == _recentCategory
              ? collection
              : null;
      _dimensionFilter = dimension;
      _favoriteCatalogIds
        ..clear()
        ..addAll(favorites);
      _recentCatalogIds
        ..clear()
        ..addAll(recent);
    });
    _publishToolbarState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.jumpTo(
        offset.clamp(0.0, _scrollController.position.maxScrollExtent),
      );
    });
  }

  void _onCatalogScrolled() {
    _scrollSaveDebounce?.cancel();
    _scrollSaveDebounce = Timer(const Duration(milliseconds: 250), () {
      unawaited(_persistBrowsingState());
    });
  }

  Future<void> _persistBrowsingState() async {
    final query = _searchController.text;
    final category = _selectedCategory;
    final collection = _selectedCollection;
    final dimension = _dimensionFilter.index;
    final favorites = _favoriteCatalogIds.toList(growable: false);
    final recent = _recentCatalogIds.toList(growable: false);
    final offset =
        _scrollController.hasClients ? _scrollController.offset : null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_queryPrefKey, query);
    await prefs.setInt(_dimensionPrefKey, dimension);
    if (collection == null) {
      await prefs.remove(_collectionPrefKey);
    } else {
      await prefs.setString(_collectionPrefKey, collection);
    }
    if (category == null) {
      await prefs.remove(_categoryPrefKey);
    } else {
      await prefs.setString(_categoryPrefKey, category);
    }
    await prefs.setStringList(_favoritesPrefKey, favorites);
    await prefs.setStringList(_recentPrefKey, recent);
    if (offset != null) {
      await prefs.setDouble(_scrollOffsetPrefKey, offset);
    }
  }

  void _onSearchChanged() {
    _searchDebouncer.schedule(() {
      if (!mounted) return;
      final nextQuery = _searchController.text;
      if (nextQuery == _debouncedQuery) return;
      _browseStateRevision++;
      setState(() => _debouncedQuery = nextQuery);
      unawaited(_persistBrowsingState());
    });
  }

  void _resetSearchInputState() {
    _searchController.clear();
    _searchDebouncer.cancel();
    _debouncedQuery = '';
    _focusNode.unfocus();
  }

  void _clearSearchInput() {
    _browseStateRevision++;
    setState(_resetSearchInputState);
    unawaited(_persistBrowsingState());
  }

  void _onSearchFocusChanged() {
    if (!mounted) return;
    setState(() => _isSearchVisible = _isSearchFocused);
    _publishToolbarState();
  }

  @override
  void dispose() {
    widget.toolbarController?.detach();
    _shimmerController.dispose();
    _searchDebouncer.dispose();
    _scrollSaveDebounce?.cancel();
    unawaited(_persistBrowsingState());
    _searchController.removeListener(_onSearchChanged);
    _focusNode.removeListener(_onSearchFocusChanged);
    _scrollController.removeListener(_onCatalogScrolled);
    _searchController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final registry = context.read<ModuleRegistry>();
    // Locale, text scale, and window changes can all revisit this hook. Avoid
    // reconstructing and regrouping all ~1000 entries unless the provider
    // actually supplies a different registry.
    if (identical(_catalogRegistry, registry)) return;
    _catalogRegistry = registry;
    _catalog = CatalogRepository.fromRegistry(registry);
  }

  Future<void> _loadViewPreference() async {
    if (!mounted) return;
    final revision = _viewModeRevision;
    final loader = widget.viewModeLoader;
    if (loader != null) {
      final mode = await loader();
      if (!mounted || revision != _viewModeRevision) return;
      setState(() => _viewMode = mode);
      _publishToolbarState();
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final modeIndex = prefs.getInt(_viewModePrefKey);
    final mode = modeIndex != null &&
            modeIndex >= 0 &&
            modeIndex < CatalogViewMode.values.length
        ? CatalogViewMode.values[modeIndex]
        : (prefs.getBool(_viewPrefKey) ?? true
            ? CatalogViewMode.grid
            : CatalogViewMode.list);
    if (!mounted || revision != _viewModeRevision) return;
    setState(() => _viewMode = mode);
    _publishToolbarState();
  }

  Future<void> _setViewMode(CatalogViewMode mode) async {
    _viewModeRevision++;
    setState(() => _viewMode = mode);
    _publishToolbarState();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_viewModePrefKey, mode.index);
    await prefs.setBool(_viewPrefKey, mode == CatalogViewMode.grid);
  }

  CatalogFilterCriteria get _currentFilterCriteria => CatalogFilterCriteria(
        query: _debouncedQuery,
        selectedCategory: _selectedCategory,
        dimensionFilter: _dimensionFilter,
      );

  void _toggleSearch() {
    if (_isSearchFocused) {
      _focusNode.unfocus();
    } else {
      _focusNode.requestFocus();
    }
  }

  void _toggleViewMode() => _setViewMode(_nextViewMode(_viewMode));

  CatalogViewMode _nextViewMode(CatalogViewMode mode) {
    switch (mode) {
      case CatalogViewMode.grid:
        return CatalogViewMode.list;
      case CatalogViewMode.list:
        return CatalogViewMode.miniatures;
      case CatalogViewMode.miniatures:
        return CatalogViewMode.grid;
    }
  }

  IconData _viewModeIcon(CatalogViewMode mode) {
    switch (mode) {
      case CatalogViewMode.grid:
        return Icons.view_list_rounded;
      case CatalogViewMode.list:
        return Icons.view_module_rounded;
      case CatalogViewMode.miniatures:
        return Icons.grid_view_rounded;
    }
  }

  String _viewModeLabel(AppLocalizations l10n, CatalogViewMode mode) {
    switch (mode) {
      case CatalogViewMode.grid:
        return l10n.catalogSwitchToList;
      case CatalogViewMode.list:
        return Localizations.localeOf(context).languageCode == 'es'
            ? 'Cambiar a miniaturas'
            : 'Switch to miniatures';
      case CatalogViewMode.miniatures:
        return l10n.catalogSwitchToGrid;
    }
  }

  void _clearCatalogRefinements() {
    _browseStateRevision++;
    setState(() {
      _resetSearchInputState();
      _isSearchVisible = false;
      _selectedCategory = null;
      _selectedCollection = null;
      _dimensionFilter = CatalogDimensionFilter.all;
      _collapsedCategories.clear();
    });
    _publishToolbarState();
    unawaited(_persistBrowsingState());
  }

  String? _normalizeCategory(String? category) {
    final categories =
        _catalog?.entries.map((entry) => entry.category).toSet() ?? <String>{};
    if (categories.contains(category)) return category;
    final normalized = switch (category) {
      'Escape-Time' ||
      'Complex Visualization' ||
      'Rational Maps' ||
      'Hypercomplex' =>
        'Complex dynamics',
      'Root Finding' ||
      'Root-Finding' ||
      'Convergent & Root-Finding' =>
        'Root finding',
      'IFS' || 'IFS & Geometric' => 'IFS and geometric constructions',
      'Attractors' ||
      'Maps & Attractors' ||
      'Strange Attractors' =>
        'Maps, flows and attractors',
      'Cellular & Stochastic' ||
      'Cellular Automata' =>
        'Cellular automata and growth',
      _ => null,
    };
    return categories.contains(normalized) ? normalized : null;
  }

  void _setSelectedCollection(String? collection) {
    if (collection == _selectedCollection) return;
    _browseStateRevision++;
    setState(() => _selectedCollection = collection);
    unawaited(_persistBrowsingState());
  }

  void _setSelectedCategory(String? category) {
    if (category == _selectedCategory) return;
    _browseStateRevision++;
    setState(() => _selectedCategory = category);
    unawaited(_persistBrowsingState());
  }

  void _toggleFavorite(String catalogId) {
    _browseStateRevision++;
    setState(() {
      if (!_favoriteCatalogIds.add(catalogId)) {
        _favoriteCatalogIds.remove(catalogId);
      }
    });
    unawaited(_persistBrowsingState());
  }

  void _recordRecentlyViewed(String catalogId) {
    _browseStateRevision++;
    setState(() {
      _recentCatalogIds
        ..remove(catalogId)
        ..insert(0, catalogId);
      if (_recentCatalogIds.length > 20) {
        _recentCatalogIds.removeRange(20, _recentCatalogIds.length);
      }
    });
    unawaited(_persistBrowsingState());
  }

  Map<String, List<CatalogEntry>> _groupAndSort(
    List<CatalogEntry> entries,
    AppLocalizations l10n, {
    required CatalogSearchQuery query,
  }) {
    final relevance = {
      for (final entry in entries)
        entry: query.isEmpty ? 0 : query.relevanceScore(entry, l10n) ?? 999,
    };
    final grouped = <String, List<CatalogEntry>>{};
    for (final entry in entries) {
      grouped.putIfAbsent(entry.category, () => []).add(entry);
    }

    final sortedEntries = grouped.entries.toList()
      ..sort((a, b) {
        if (!query.isEmpty) {
          final aScore = a.value
              .map((entry) => relevance[entry] ?? 999)
              .reduce((left, right) => left < right ? left : right);
          final bScore = b.value
              .map((entry) => relevance[entry] ?? 999)
              .reduce((left, right) => left < right ? left : right);
          final scoreCompare = aScore.compareTo(bScore);
          if (scoreCompare != 0) return scoreCompare;
        }
        final priorityCompare = _categorySortPriority(a.key)
            .compareTo(_categorySortPriority(b.key));
        if (priorityCompare != 0) return priorityCompare;
        final countCompare = b.value.length.compareTo(a.value.length);
        if (countCompare != 0) return countCompare;
        return a.key.compareTo(b.key);
      });

    final sections = <String, List<CatalogEntry>>{};
    for (final section in sortedEntries) {
      final sorted = List<CatalogEntry>.from(section.value)
        ..sort((a, b) {
          if (!query.isEmpty) {
            final scoreCompare =
                (relevance[a] ?? 999).compareTo(relevance[b] ?? 999);
            if (scoreCompare != 0) return scoreCompare;
          }
          final nameCompare =
              a.module.displayName(l10n).compareTo(b.module.displayName(l10n));
          return nameCompare != 0
              ? nameCompare
              : a.catalogId.compareTo(b.catalogId);
        });
      final variants = <String, List<CatalogEntry>>{};
      for (final entry in sorted) {
        final groupId = entry.mathematics.groupId;
        variants.putIfAbsent(groupId, () => []).add(entry);
      }
      final familyLabel = mathematicalLabel(context, section.key);
      final independent = variants.values
          .where((group) => group.length == 1)
          .expand((group) => group)
          .toList();
      if (independent.isNotEmpty) sections[familyLabel] = independent;
      for (final group in variants.values.where((group) => group.length > 1)) {
        final math = group.first.mathematics;
        // groupId is an explicit reviewed recurrence, never a shader-path guess.
        final title =
            '$familyLabel · ${mathematicalLabel(context, math.relationship)}';
        sections[title] = group;
      }
    }
    if (query.isEmpty) return sections;
    final matchOrder = {for (var i = 0; i < entries.length; i++) entries[i]: i};
    final rankedSections = sections.entries.toList()
      ..sort((a, b) {
        int firstMatch(List<CatalogEntry> group) =>
            group.map((entry) => matchOrder[entry]!).reduce(math.min);
        return firstMatch(a.value).compareTo(firstMatch(b.value));
      });
    return Map.fromEntries(rankedSections);
  }

  int _categorySortPriority(String category) {
    if (category == 'Complex dynamics') return 0;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final filterCriteria = _currentFilterCriteria;
    final filterResult = CatalogFilter.apply(
      entries: switch (_selectedCollection) {
        _favoritesCategory => _catalog!.entries
            .where((entry) => _favoriteCatalogIds.contains(entry.catalogId)),
        _recentCategory => _catalog!.entries
            .where((entry) => _recentCatalogIds.contains(entry.catalogId)),
        _ => _catalog!.entries,
      },
      criteria: filterCriteria,
      l10n: l10n,
    );
    final query = filterCriteria.searchQuery.value;
    final baseEntries = filterResult.filteredEntries;
    final filteredEntries = switch (_selectedCollection) {
      _favoritesCategory => baseEntries
          .where((entry) => _favoriteCatalogIds.contains(entry.catalogId))
          .toList(growable: false),
      _recentCategory => <CatalogEntry>[
          for (final catalogId in _recentCatalogIds)
            ...baseEntries.where((entry) => entry.catalogId == catalogId),
        ],
      _ => baseEntries,
    };
    final groupedEntries = _selectedCollection == _recentCategory
        ? <String, List<CatalogEntry>>{
            _categoryDisplayLabel(_recentCategory): filteredEntries
          }
        : _groupAndSort(filteredEntries, l10n,
            query: filterCriteria.searchQuery);
    return GestureDetector(
      key: const Key('catalogCategorySwipeArea'),
      behavior: HitTestBehavior.opaque,
      onHorizontalDragEnd: (details) => _handleCategorySwipe(
        details,
        filterResult,
      ),
      child: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.cosmicGradient),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverPersistentHeader(
              key: const Key('catalogPinnedFilterBar'),
              pinned: true,
              delegate: _PinnedHeaderDelegate(
                height: _pinnedFilterBarHeight(context),
                child: _buildPinnedTopBar(context, l10n, filterResult),
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
            else if (_viewMode == CatalogViewMode.list)
              _buildListContentSliver(groupedEntries, l10n)
            else
              _buildGridContentSliver(
                groupedEntries,
                l10n,
                miniatures: _viewMode == CatalogViewMode.miniatures,
              ),
          ],
        ),
      ),
    );
  }

  void _handleCategorySwipe(
    DragEndDetails details,
    CatalogFilterResult filterResult,
  ) {
    if (_isSearchFocused) return;
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
    _setSelectedCategory(nextCategory);
    AccessibilityService.announce(_categoryDisplayLabel(nextCategory));
  }

  String _categoryDisplayLabel(String? category) {
    if (category == null) return _allCategoriesLabel(context);
    final isSpanish = Localizations.localeOf(context).languageCode == 'es';
    if (category == _favoritesCategory) {
      return isSpanish ? 'Favoritos' : 'Favorites';
    }
    if (category == _recentCategory) return isSpanish ? 'Recientes' : 'Recent';
    return mathematicalLabel(context, category);
  }

  void _toggleCategorySection(String category) {
    setState(() {
      if (!_collapsedCategories.add(category)) {
        _collapsedCategories.remove(category);
      }
    });
  }

  List<String?> _categoryChoices(CatalogFilterResult filterResult) {
    final counts = CatalogFilter.countCategories(_catalog!.entries);
    final categories = counts.keys.toList()
      ..sort((a, b) {
        final countCompare = (counts[b] ?? 0).compareTo(counts[a] ?? 0);
        if (countCompare != 0) return countCompare;
        return a.compareTo(b);
      });
    return [null, ...categories];
  }

  /// Height of the pinned filter bar.
  ///
  /// A SliverPersistentHeader needs a fixed extent, so this cannot be measured
  /// from the content. The bar is mostly fixed padding around a single line of
  /// chip text, which is why it overflowed by only 2px at a 3.0x accessibility
  /// text scale -- so the extent grows by however much that text grows rather
  /// than by the whole scale factor, which would reserve 240px for content
  /// needing 82.
  static double _pinnedFilterBarHeight(BuildContext context) {
    const base = 200.0;
    const chipFontSize = 12.0;
    final scaled = MediaQuery.textScalerOf(context).scale(chipFontSize);
    return base + (scaled - chipFontSize).clamp(0.0, 48.0) * 4;
  }

  Widget _buildPinnedTopBar(
    BuildContext context,
    AppLocalizations l10n,
    CatalogFilterResult filterResult,
  ) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.96),
        border: Border(
          bottom: BorderSide(color: AppColors.border.withValues(alpha: 0.6)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSearchAndCollections(context, l10n, filterResult),
          _buildFilterAndSortBar(context, l10n, filterResult),
        ],
      ),
    );
  }

  Widget _buildSearchAndCollections(
    BuildContext context,
    AppLocalizations l10n,
    CatalogFilterResult result,
  ) {
    final isSpanish = Localizations.localeOf(context).languageCode == 'es';
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.xs, AppSpacing.lg, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCompactSearchField(context, l10n),
          const SizedBox(height: AppSpacing.xs),
          SingleChildScrollView(
            key: const Key('catalogCollectionAndDimensionScroll'),
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _DimChip(
                  chipKey: const Key('catalogCollectionChip_explore'),
                  label: isSpanish ? 'Explorar' : 'Explore',
                  count: _catalog!.entries.length,
                  selected: _selectedCollection == null,
                  onTap: () => _setSelectedCollection(null),
                ),
                const SizedBox(width: AppSpacing.xs),
                _DimChip(
                  chipKey: const Key('catalogCategoryChip_favorites'),
                  label: _categoryDisplayLabel(_favoritesCategory),
                  count: _favoriteCatalogIds.length,
                  selected: _selectedCollection == _favoritesCategory,
                  onTap: () => _setSelectedCollection(_favoritesCategory),
                ),
                const SizedBox(width: AppSpacing.xs),
                _DimChip(
                  chipKey: const Key('catalogCategoryChip_recent'),
                  label: _categoryDisplayLabel(_recentCategory),
                  count: _recentCatalogIds.length,
                  selected: _selectedCollection == _recentCategory,
                  onTap: () => _setSelectedCollection(_recentCategory),
                ),
                const SizedBox(width: AppSpacing.md),
                for (final filter in const [
                  CatalogDimensionFilter.all,
                  CatalogDimensionFilter.twoD,
                  CatalogDimensionFilter.threeD
                ]) ...[
                  _DimChip(
                    chipKey: Key('catalogDimensionChip_${switch (filter) {
                      CatalogDimensionFilter.twoD => '2d',
                      CatalogDimensionFilter.threeD => '3d',
                      _ => 'all'
                    }}'),
                    label: switch (filter) {
                      CatalogDimensionFilter.twoD => l10n.dimension2d,
                      CatalogDimensionFilter.threeD => l10n.dimension3d,
                      _ =>
                        isSpanish ? 'Todas las dimensiones' : 'All dimensions',
                    },
                    count: result.countForDimension(filter),
                    selected: _dimensionFilter == filter,
                    onTap: () {
                      _browseStateRevision++;
                      setState(() => _dimensionFilter = filter);
                      unawaited(_persistBrowsingState());
                    },
                  ),
                  const SizedBox(width: AppSpacing.xs),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterAndSortBar(
    BuildContext context,
    AppLocalizations l10n,
    CatalogFilterResult filterResult,
  ) {
    final categories = CatalogFilter.sortCategories(
      CatalogFilter.countCategories(_catalog!.entries),
      selectedCategory: _selectedCategory,
    );
    final categoryCounts = filterResult.categoryCounts;
    final totalCategoryCount = filterResult.categoryBaseEntries.length;
    final allCategoriesLabel = _allCategoriesLabel(context);
    final showLocalActions = widget.toolbarController == null;

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
              child: _CategoryFilterRail(
                allCategoriesLabel: allCategoriesLabel,
                totalCategoryCount: totalCategoryCount,
                categories: categories,
                categoryCounts: categoryCounts,
                selectedCategory: _selectedCategory,
                onSelect: (category) => _setSelectedCategory(
                  category == _selectedCategory ? null : category,
                ),
              ),
            ),
            if (showLocalActions) ...[
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
                icon: _viewModeIcon(_viewMode),
                semanticLabel: _viewModeLabel(l10n, _viewMode),
                onTap: _toggleViewMode,
              ),
            ],
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
      label: Localizations.localeOf(context).languageCode == 'es'
          ? 'Buscar por nombre, fórmula o familia'
          : 'Search by name, formula or family',
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
          hintText: Localizations.localeOf(context).languageCode == 'es'
              ? 'Nombre, fórmula o familia'
              : 'Name, formula or family',
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

  String _allCategoriesLabel(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'es'
        ? 'Todas las categorías'
        : 'All categories';
  }

  Widget _buildListContentSliver(
    Map<String, List<CatalogEntry>> groupedEntries,
    AppLocalizations l10n,
  ) {
    // Flatten grouped entries into a flat list where each item is either
    // a section header, a card, or spacing.
    final flatItems = <_ListItem>[];
    for (final section in groupedEntries.entries) {
      final collapsed = _collapsedCategories.contains(section.key);
      flatItems.add(_ListItem.header(section.key, section.value.length));
      if (!collapsed) {
        for (final entry in section.value) {
          flatItems.add(_ListItem.card(entry));
        }
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
              child: _SectionHeader(
                title: item.title!,
                count: item.count!,
                collapsed: _collapsedCategories.contains(item.title!),
                onToggle: () => _toggleCategorySection(item.title!),
              ),
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
                  isFavorite: _favoriteCatalogIds.contains(entry.catalogId),
                  onFavoriteToggle: () => _toggleFavorite(entry.catalogId),
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
    AppLocalizations l10n, {
    bool miniatures = false,
  }) {
    return SliverLayoutBuilder(builder: (context, constraints) {
      final width = constraints.crossAxisExtent;
      final crossAxisCount = miniatures
          ? 4
          : width >= 1024
              ? 5
              : width >= 840
                  ? 4
                  : width >= 600
                      ? 3
                      : 2;
      final textScale = MediaQuery.textScalerOf(context).scale(13) / 13;
      final accessibleColumns =
          textScale >= 2 ? math.max(1, crossAxisCount ~/ 2) : crossAxisCount;
      final tileWidth = (width -
              AppSpacing.lg * 2 -
              (accessibleColumns - 1) *
                  (miniatures ? AppSpacing.xs : AppSpacing.md)) /
          accessibleColumns;
      final tileHeight = miniatures
          ? tileWidth
          : tileWidth * 0.9 + _catalogCaptionHeight(context);
      final spacing = miniatures ? AppSpacing.xs : AppSpacing.md;
      final children = <Widget>[];
      var sectionIndex = 0;

      for (final section in groupedEntries.entries) {
        final sectionSlug = slugify(section.key);
        final sectionKey = '${sectionSlug}_$sectionIndex';
        sectionIndex += 1;
        children.add(
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                top: AppSpacing.md,
              ),
              child: _SectionHeader(
                title: section.key,
                count: section.value.length,
                collapsed: _collapsedCategories.contains(section.key),
                onToggle: () => _toggleCategorySection(section.key),
              ),
            ),
          ),
        );
        if (_collapsedCategories.contains(section.key)) {
          children.add(
            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.sm),
            ),
          );
          continue;
        }
        children.add(
          SliverPadding(
            key: Key('catalogSectionGrid_$sectionKey'),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final entry = section.value[index];
                  return RepaintBoundary(
                    child: _ModuleGridTile(
                      entry: entry,
                      l10n: l10n,
                      isFavorite: _favoriteCatalogIds.contains(entry.catalogId),
                      onFavoriteToggle: () => _toggleFavorite(entry.catalogId),
                      miniatures: miniatures,
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
                crossAxisCount: accessibleColumns,
                mainAxisSpacing: spacing,
                crossAxisSpacing: spacing,
                mainAxisExtent: tileHeight,
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
    });
  }

  void _openViewer(
    BuildContext context,
    FractalModule module, {
    String? heroTag,
    CatalogFamily catalogFamily = CatalogFamily.core,
  }) {
    if (heroTag != null) _recordRecentlyViewed(heroTag);
    final controller = context.read<FractalController>();
    controller.selectModule(module, animate: false);
    controller.applyPreset(module.defaultPreset);
    final viewOverride =
        heroTag == null ? null : CatalogThumbnailCache.viewOverrideFor(heroTag);
    if (viewOverride != null) {
      final pan = controller.view.pan
        ..setValues(viewOverride.centerX, viewOverride.centerY);
      controller.updateView(
          controller.view.copyWith(pan: pan, zoom: viewOverride.zoom));
    }
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: controller),
          ],
          child: FractalViewerScreen(
            catalogFamily: catalogFamily,
            restoreViewerSession: false,
          ),
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

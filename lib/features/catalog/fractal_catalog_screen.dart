import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/services/accessibility_service.dart';
import 'package:flutter_fractals/core/services/runtime_mode_service.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/features/catalog/catalog_entry.dart';
import 'package:flutter_fractals/features/catalog/catalog_exports.dart';
import 'package:flutter_fractals/features/catalog/catalog_repository.dart';
import 'package:flutter_fractals/features/catalog/catalog_screen_data.dart';
import 'package:flutter_fractals/features/catalog/catalog_view_mode_store.dart';
import 'package:flutter_fractals/features/renderer/providers/fractal_provider.dart';
import 'package:flutter_fractals/features/viewer/fractal_viewer_screen.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';

class FractalCatalogScreen extends StatefulWidget {
  final CatalogViewModeStore viewModeStore;

  const FractalCatalogScreen({
    super.key,
    this.viewModeStore = const SharedPreferencesCatalogViewModeStore(),
  });

  @override
  State<FractalCatalogScreen> createState() => _FractalCatalogScreenState();
}

class _FractalCatalogScreenState extends State<FractalCatalogScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  ModuleRegistry? _registry;
  CatalogScreenDataBuilder? _catalogDataBuilder;
  bool _isSearchFocused = false;
  bool _hasUserChangedViewMode = false;
  CatalogViewMode _viewMode = CatalogViewMode.grid;
  CatalogDimensionFilter _dimensionFilter = CatalogDimensionFilter.all;
  CatalogSortOrder _sortOrder = CatalogSortOrder.byCategory;
  String? _selectedCategory;
  Future<void> _pendingViewModeSave = Future<void>.value();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_handleSearchChanged);
    _focusNode.addListener(_handleFocusChanged);
    _loadViewPreference();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final registry = context.read<ModuleRegistry>();
    if (identical(_registry, registry)) {
      return;
    }

    _registry = registry;
    final catalog = CatalogRepository.fromRegistry(registry);
    _catalogDataBuilder = CatalogScreenDataBuilder(entries: catalog.entries);
  }

  void _handleSearchChanged() {
    setState(() {});
  }

  void _handleFocusChanged() {
    final isFocused = _focusNode.hasFocus;
    if (_isSearchFocused == isFocused) {
      return;
    }

    setState(() {
      _isSearchFocused = isFocused;
    });
  }

  Future<void> _loadViewPreference() async {
    final viewMode = await widget.viewModeStore.load();
    if (!mounted || _hasUserChangedViewMode) {
      return;
    }

    setState(() {
      _viewMode = viewMode;
    });
  }

  Future<void> _setViewMode(CatalogViewMode mode) async {
    if (_viewMode == mode) {
      return;
    }

    _hasUserChangedViewMode = true;
    setState(() => _viewMode = mode);
    _pendingViewModeSave = _pendingViewModeSave
        .catchError((Object _) {})
        .then((_) => widget.viewModeStore.save(mode));
    await _pendingViewModeSave;
  }

  @override
  void dispose() {
    _searchController.removeListener(_handleSearchChanged);
    _focusNode.removeListener(_handleFocusChanged);
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _clearCatalogRefinements() {
    _searchController.clear();
    _focusNode.unfocus();
    setState(() {
      _dimensionFilter = CatalogDimensionFilter.all;
      _sortOrder = CatalogSortOrder.byCategory;
      _selectedCategory = null;
    });
  }

  void _updateDimensionFilter(CatalogDimensionFilter filter) {
    if (_dimensionFilter == filter) {
      return;
    }

    setState(() {
      _dimensionFilter = filter;
    });
  }

  @override
  Widget build(BuildContext context) {
    final catalogDataBuilder = _catalogDataBuilder;
    if (catalogDataBuilder == null) {
      return const SizedBox.shrink();
    }

    final mediaQuery = MediaQuery.of(context);
    final isKeyboardVisible = mediaQuery.viewInsets.bottom > 0;
    final l10n = AppLocalizations.of(context)!;
    final screenData = catalogDataBuilder.build(
      l10n: l10n,
      searchQuery: _searchController.text,
      dimensionFilter: _dimensionFilter,
      sortOrder: _sortOrder,
      selectedCategory: _selectedCategory,
    );
    final showSupportingChrome = !_isSearchFocused &&
        screenData.normalizedQuery.isEmpty &&
        !screenData.isEmpty &&
        !isKeyboardVisible;

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
              Expanded(
                child: _buildSearchField(
                  context,
                  l10n,
                  hasActiveQuery: screenData.normalizedQuery.isNotEmpty,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              _buildViewToggle(context, l10n),
            ],
          ),
        ),
        Expanded(
          child: screenData.isEmpty
              ? CatalogEmptyState(
                  query: screenData.normalizedQuery,
                  l10n: l10n,
                  onClear: _clearCatalogRefinements,
                )
              : _buildCatalogContent(
                  context,
                  screenData,
                  l10n,
                  showSupportingChrome: showSupportingChrome,
                ),
        ),
      ],
    );
  }

  Widget _buildCatalogContent(
    BuildContext context,
    CatalogScreenData screenData,
    AppLocalizations l10n, {
    required bool showSupportingChrome,
  }) {
    if (_viewMode == CatalogViewMode.grid) {
      return _buildGridContent(
        context,
        screenData,
        l10n,
        showSupportingChrome: showSupportingChrome,
      );
    }

    return _buildListContent(
      context,
      screenData,
      l10n,
      showSupportingChrome: showSupportingChrome,
    );
  }

  Widget _buildSearchField(
    BuildContext context,
    AppLocalizations l10n, {
    required bool hasActiveQuery,
  }) {
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
              child: hasActiveQuery
                  ? IconButton(
                      key: const ValueKey('clear'),
                      tooltip:
                          MaterialLocalizations.of(context).deleteButtonTooltip,
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: _searchController.clear,
                    )
                  : const SizedBox.shrink(),
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildViewToggle(BuildContext context, AppLocalizations l10n) {
    final isGrid = _viewMode == CatalogViewMode.grid;
    final nextMode = isGrid ? CatalogViewMode.list : CatalogViewMode.grid;
    final actionLabel =
        isGrid ? l10n.catalogSwitchToList : l10n.catalogSwitchToGrid;

    return Semantics(
      button: true,
      label: actionLabel,
      child: Tooltip(
        message: isGrid ? l10n.catalogListView : l10n.catalogGridView,
        child: ExcludeSemantics(
          child: IconButton(
            key: const Key('catalogViewToggleButton'),
            tooltip: actionLabel,
            onPressed: () => _setViewMode(nextMode),
            icon: Icon(
              isGrid ? Icons.view_list_rounded : Icons.grid_view_rounded,
              color: AppColors.textMuted,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterAndSortBar(
    BuildContext context,
    AppLocalizations l10n,
    CatalogScreenData screenData,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  CatalogDimChip(
                    chipKey: const Key('catalogDimensionChip_all'),
                    label: l10n.catalogFilterAll,
                    count: screenData.dimensionCounts.all,
                    selected: _dimensionFilter == CatalogDimensionFilter.all,
                    onTap: () =>
                        _updateDimensionFilter(CatalogDimensionFilter.all),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  CatalogDimChip(
                    chipKey: const Key('catalogDimensionChip_2d'),
                    label: l10n.dimension2d,
                    count: screenData.dimensionCounts.twoD,
                    selected: _dimensionFilter == CatalogDimensionFilter.twoD,
                    onTap: () =>
                        _updateDimensionFilter(CatalogDimensionFilter.twoD),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  CatalogDimChip(
                    chipKey: const Key('catalogDimensionChip_3d'),
                    label: l10n.dimension3d,
                    count: screenData.dimensionCounts.threeD,
                    selected: _dimensionFilter == CatalogDimensionFilter.threeD,
                    onTap: () =>
                        _updateDimensionFilter(CatalogDimensionFilter.threeD),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          PopupMenuButton<CatalogSortOrder>(
            tooltip: l10n.catalogFilterSortOrder,
            initialValue: _sortOrder,
            onSelected: (value) {
              if (_sortOrder == value) {
                return;
              }

              setState(() {
                _sortOrder = value;
              });
            },
            itemBuilder: (_) => [
              PopupMenuItem<CatalogSortOrder>(
                value: CatalogSortOrder.byCategory,
                child: Text(l10n.catalogSortByCategory),
              ),
              PopupMenuItem<CatalogSortOrder>(
                value: CatalogSortOrder.alphabetical,
                child: Text(l10n.catalogSortAlphabetical),
              ),
            ],
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
              child: Icon(
                Icons.sort_rounded,
                size: 20,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBar(
    BuildContext context,
    AppLocalizations l10n,
    CatalogScreenData screenData,
  ) {
    if (screenData.sortedCategories.isEmpty) {
      return const SizedBox.shrink();
    }

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
              itemCount: screenData.sortedCategories.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.xs),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return CatalogDimChip(
                    chipKey: const Key('catalogCategoryChip_all'),
                    label: l10n.catalogFilterAll,
                    count: screenData.categoryScopeCount,
                    selected: _selectedCategory == null,
                    onTap: () {
                      if (_selectedCategory == null) {
                        return;
                      }

                      setState(() {
                        _selectedCategory = null;
                      });
                    },
                  );
                }

                final category = screenData.sortedCategories[index - 1];
                return CatalogDimChip(
                  chipKey:
                      Key('catalogCategoryChip_${catalogKeySegment(category)}'),
                  label: category,
                  count: screenData.categoryCounts[category] ?? 0,
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
    AppLocalizations l10n,
    CatalogScreenData screenData,
  ) {
    final sortLabel = _sortOrder == CatalogSortOrder.byCategory
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
            CatalogSummaryPill(
              icon: Icons.auto_awesome_mosaic_rounded,
              label: l10n.catalogResults,
              value: '${screenData.resultCount}',
            ),
            CatalogSummaryPill(
              icon: Icons.category_rounded,
              label: l10n.catalogCategories,
              value: '${screenData.visibleCategoryCount}',
            ),
            CatalogSummaryPill(
              icon: _viewMode == CatalogViewMode.grid
                  ? Icons.grid_view_rounded
                  : Icons.view_list_rounded,
              label: viewLabel,
            ),
            CatalogSummaryPill(
              icon: Icons.sort_rounded,
              label: sortLabel,
            ),
            if (_selectedCategory != null)
              CatalogSummaryPill(
                icon: Icons.filter_alt_rounded,
                label: _selectedCategory!,
              ),
            if (screenData.hasActiveRefinements)
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

  Widget _buildListContent(
    BuildContext context,
    CatalogScreenData screenData,
    AppLocalizations l10n, {
    required bool showSupportingChrome,
  }) {
    final children = <Widget>[
      ..._buildScrollableSupportingChrome(
        context,
        l10n,
        screenData,
        showSupportingChrome: showSupportingChrome,
      ),
    ];

    for (final section in screenData.sections) {
      children.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child:
              CatalogSectionHeader(title: section.title, count: section.count),
        ),
      );
      for (final entry in section.entries) {
        children.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: CatalogListCard(
              entry: entry,
              semanticLabel: screenData.semanticLabelFor(entry),
              onTap: () =>
                  _openViewer(context, entry.module, heroTag: entry.catalogId),
              l10n: l10n,
            ),
          ),
        );
      }
      children.add(const SizedBox(height: AppSpacing.lg));
    }

    return ListView(
      padding: EdgeInsets.only(
        top: AppSpacing.sm,
        bottom: MediaQuery.of(context).padding.bottom + 100,
      ),
      children: children,
    );
  }

  Widget _buildGridContent(
    BuildContext context,
    CatalogScreenData screenData,
    AppLocalizations l10n, {
    required bool showSupportingChrome,
  }) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = CatalogConstants.gridCrossAxisCount(width);

    return ListView(
      padding: EdgeInsets.only(
        top: AppSpacing.sm,
        bottom: MediaQuery.of(context).padding.bottom + 100,
      ),
      children: [
        ..._buildScrollableSupportingChrome(
          context,
          l10n,
          screenData,
          showSupportingChrome: showSupportingChrome,
        ),
        ...screenData.sections.map((section) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CatalogSectionHeader(
                    title: section.title, count: section.count),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: section.entries.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: AppSpacing.sm,
                    mainAxisSpacing: AppSpacing.sm,
                    childAspectRatio: 0.9,
                  ),
                  itemBuilder: (context, index) {
                    final entry = section.entries[index];
                    return CatalogGridTile(
                      entry: entry,
                      semanticLabel: screenData.semanticLabelFor(entry),
                      l10n: l10n,
                      onTap: () => _openViewer(context, entry.module,
                          heroTag: entry.catalogId),
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            ),
          );
        }),
      ],
    );
  }

  List<Widget> _buildScrollableSupportingChrome(
    BuildContext context,
    AppLocalizations l10n,
    CatalogScreenData screenData, {
    required bool showSupportingChrome,
  }) {
    if (!showSupportingChrome) {
      return const <Widget>[];
    }

    return <Widget>[
      _buildFilterAndSortBar(context, l10n, screenData),
      _buildCategoryBar(context, l10n, screenData),
      _buildCatalogSummary(context, l10n, screenData),
      if (screenData.showFeatured)
        CatalogFeaturedSection(
          screenData: screenData,
          l10n: l10n,
          onTap: (entry) =>
              _openViewer(context, entry.module, heroTag: entry.catalogId),
        ),
    ];
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

enum _CatalogListItemType { header, entry, spacer }

@immutable
class _CatalogListItem {
  final _CatalogListItemType type;
  final CatalogSection? section;
  final CatalogEntry? entry;

  const _CatalogListItem._({
    required this.type,
    this.section,
    this.entry,
  });

  const _CatalogListItem.header(CatalogSection section)
      : this._(
          type: _CatalogListItemType.header,
          section: section,
        );

  const _CatalogListItem.entry(CatalogEntry entry)
      : this._(
          type: _CatalogListItemType.entry,
          entry: entry,
        );

  const _CatalogListItem.spacer()
      : this._(
          type: _CatalogListItemType.spacer,
        );
}

// ---------------------------------------------------------------------------
// Shared section header with colored left border and count badge
// ---------------------------------------------------------------------------

class CatalogSectionHeader extends StatelessWidget {
  final String title;
  final int count;

  const CatalogSectionHeader({required this.title, required this.count});

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
// Dimension filter chip
// ---------------------------------------------------------------------------

class CatalogDimChip extends StatelessWidget {
  final Key? chipKey;
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  const CatalogDimChip({
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

class CatalogSummaryPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;

  const CatalogSummaryPill({
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

class CatalogGridTile extends StatefulWidget {
  final CatalogEntry entry;
  final String semanticLabel;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  const CatalogGridTile({
    required this.entry,
    required this.semanticLabel,
    required this.l10n,
    required this.onTap,
  });

  @override
  State<CatalogGridTile> createState() => CatalogGridTileState();
}

class CatalogGridTileState extends State<CatalogGridTile>
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
    final accentColor = categoryAccentColor(widget.entry.category);

    return Semantics(
      label: widget.semanticLabel,
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
                          CatalogPreviewThumbnail(
                            catalogId: widget.entry.catalogId,
                            is3D: is3D,
                            category: widget.entry.category,
                          ),
                          // Gradient overlay for text
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: ExcludeSemantics(
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

class CatalogEmptyState extends StatelessWidget {
  final String query;
  final AppLocalizations l10n;
  final VoidCallback onClear;

  const CatalogEmptyState({
    required this.query,
    required this.l10n,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: AppAnimations.normal,
      curve: AppAnimations.defaultCurve,
      builder: (context, opacity, child) {
        return Opacity(
          opacity: opacity,
          child: child,
        );
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxHeight < 280;
          final contentPadding = isCompact ? AppSpacing.lg : AppSpacing.xxxl;
          final iconPadding = isCompact ? AppSpacing.md : AppSpacing.xl;
          final iconSize = isCompact ? 28.0 : 36.0;
          final spacing = isCompact ? AppSpacing.sm : AppSpacing.lg;

          return SingleChildScrollView(
            padding: EdgeInsets.all(contentPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(iconPadding),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.search_off_rounded,
                    size: iconSize,
                    color: AppColors.textMuted,
                  ),
                ),
                SizedBox(height: spacing),
                Text(
                  l10n.catalogSearchEmpty,
                  style: AppTypography.bodyLarge
                      .copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                if (query.isNotEmpty) ...[
                  SizedBox(height: spacing),
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
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Featured hero carousel
// ---------------------------------------------------------------------------

class CatalogFeaturedSection extends StatelessWidget {
  final CatalogScreenData screenData;
  final AppLocalizations l10n;
  final ValueChanged<CatalogEntry> onTap;

  const CatalogFeaturedSection({
    required this.screenData,
    required this.l10n,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (screenData.featuredEntries.isEmpty) {
      return const SizedBox.shrink();
    }

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
            itemCount: screenData.featuredEntries.length,
            itemBuilder: (context, index) {
              final entry = screenData.featuredEntries[index];
              return Padding(
                key: ValueKey('featured_${entry.catalogId}'),
                padding: EdgeInsets.only(
                  right: index < screenData.featuredEntries.length - 1
                      ? AppSpacing.sm
                      : 0,
                ),
                child: CatalogFeaturedCard(
                  entry: entry,
                  semanticLabel: screenData.semanticLabelFor(entry),
                  l10n: l10n,
                  onTap: () => onTap(entry),
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

class CatalogFeaturedCard extends StatefulWidget {
  final CatalogEntry entry;
  final String semanticLabel;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  const CatalogFeaturedCard({
    required this.entry,
    required this.semanticLabel,
    required this.l10n,
    required this.onTap,
  });

  @override
  State<CatalogFeaturedCard> createState() => CatalogFeaturedCardState();
}

class CatalogFeaturedCardState extends State<CatalogFeaturedCard>
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
        parent: _scaleController,
        curve: AppAnimations.snappyCurve,
      ),
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
    final accentColor = categoryAccentColor(widget.entry.category);

    return Semantics(
      label: widget.semanticLabel,
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
                        CatalogPreviewThumbnail(
                          catalogId: widget.entry.catalogId,
                          is3D: is3D,
                          category: widget.entry.category,
                        ),
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

class CatalogListCard extends StatefulWidget {
  final CatalogEntry entry;
  final String semanticLabel;
  final VoidCallback onTap;
  final AppLocalizations l10n;

  const CatalogListCard({
    required this.entry,
    required this.semanticLabel,
    required this.onTap,
    required this.l10n,
  });

  @override
  State<CatalogListCard> createState() => CatalogListCardState();
}

class CatalogListCardState extends State<CatalogListCard>
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

    final reduceMotion = MediaQuery.of(context).disableAnimations ||
        (context.read<AccessibilityService?>()?.reducedMotionEnabled ?? false);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Semantics(
        label: widget.semanticLabel,
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
            CatalogPreviewThumbnail(
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

String catalogKeySegment(String value) {
  return value
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_+|_+$'), '');
}

/// Returns the accent color for a given fractal category string.
Color categoryAccentColor(String category) {
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

class CatalogPreviewThumbnail extends StatefulWidget {
  final String catalogId;
  final bool is3D;
  final String category;
  final double? size;

  const CatalogPreviewThumbnail({
    required this.catalogId,
    required this.is3D,
    required this.category,
    this.size,
  });

  @override
  State<CatalogPreviewThumbnail> createState() =>
      CatalogPreviewThumbnailState();
}

class CatalogPreviewThumbnailState extends State<CatalogPreviewThumbnail>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerController;
  late final bool _animateShimmer;
  bool _imageLoaded = false;
  bool _imageError = false;

  bool get _hasExactCpuThumbnail {
    final thumbId = widget.catalogId.startsWith('core.')
        ? widget.catalogId.substring(5)
        : widget.catalogId;
    return kKnownThumbnailIds.contains(thumbId);
  }

  @override
  void initState() {
    super.initState();
    _animateShimmer = !RuntimeModeService.isAutomatedTest;
    _shimmerController = AnimationController(
      vsync: this,
      duration: AppAnimations.shimmer,
    );
    if (_animateShimmer) {
      _shimmerController.repeat();
    }
  }

  void _markImageLoaded() {
    if (_imageLoaded) return;
    if (_shimmerController.isAnimating) {
      _shimmerController.stop();
    }
    if (!mounted) return;
    setState(() => _imageLoaded = true);
  }

  void _markImageError() {
    if (_imageError) return;
    if (_shimmerController.isAnimating) {
      _shimmerController.stop();
    }
    if (!mounted) return;
    setState(() => _imageError = true);
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
    final accentColor = categoryAccentColor(widget.category);

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
            ThumbnailShimmerSkeleton(controller: _shimmerController),

          // Image (or gradient fallback on error)
          Positioned.fill(
            child: Image.asset(
              thumbAsset,
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
                  duration:
                      imageReady ? Duration.zero : AppAnimations.thumbnailFade,
                  child: child,
                );
              },
              errorBuilder: (context, error, stack) {
                if (!_imageError) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _markImageError();
                  });
                }
                return ThumbnailGradientFallback(
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

class ThumbnailShimmerSkeleton extends StatelessWidget {
  final AnimationController controller;
  const ThumbnailShimmerSkeleton({required this.controller});

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

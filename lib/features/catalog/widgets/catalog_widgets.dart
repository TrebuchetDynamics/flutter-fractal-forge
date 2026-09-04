part of '../fractal_catalog_screen.dart';

// ---------------------------------------------------------------------------
// Shared section header with colored left border and count badge
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final bool collapsed;
  final VoidCallback? onToggle;

  const _SectionHeader({
    required this.title,
    required this.count,
    this.collapsed = false,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Semantics(
      header: true,
      button: onToggle != null,
      expanded: onToggle == null ? null : !collapsed,
      label: l10n.semanticSectionHeader(title, count),
      child: InkWell(
        key: Key('catalogSectionHeader_${slugify(title)}'),
        borderRadius: BorderRadius.circular(8),
        onTap: onToggle,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
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
                ExcludeSemantics(
                  child: Icon(
                    collapsed
                        ? Icons.keyboard_arrow_right_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                // Count badge (decorative; count is already in the Semantics label)
                ExcludeSemantics(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Category filter rail
// ---------------------------------------------------------------------------

class _CategoryFilterRail extends StatelessWidget {
  final String allCategoriesLabel;
  final String favoritesLabel;
  final String recentLabel;
  final int favoriteCount;
  final int recentCount;
  final int totalCategoryCount;
  final List<String> categories;
  final Map<String, int> categoryCounts;
  final String? selectedCategory;
  final ValueChanged<String?> onSelect;

  const _CategoryFilterRail({
    required this.allCategoriesLabel,
    required this.favoritesLabel,
    required this.recentLabel,
    required this.favoriteCount,
    required this.recentCount,
    required this.totalCategoryCount,
    required this.categories,
    required this.categoryCounts,
    required this.selectedCategory,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: const Key('catalogCategoryScroll'),
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _DimChip(
            chipKey: const Key('catalogCategoryChip_all'),
            label: allCategoriesLabel,
            count: totalCategoryCount,
            selected: selectedCategory == null,
            onTap: () => onSelect(null),
          ),
          const SizedBox(width: AppSpacing.xs),
          _DimChip(
            chipKey: const Key('catalogCategoryChip_favorites'),
            label: favoritesLabel,
            count: favoriteCount,
            selected: selectedCategory ==
                _FractalCatalogScreenState._favoritesCategory,
            onTap: () =>
                onSelect(_FractalCatalogScreenState._favoritesCategory),
          ),
          const SizedBox(width: AppSpacing.xs),
          _DimChip(
            chipKey: const Key('catalogCategoryChip_recent'),
            label: recentLabel,
            count: recentCount,
            selected:
                selectedCategory == _FractalCatalogScreenState._recentCategory,
            onTap: () => onSelect(_FractalCatalogScreenState._recentCategory),
          ),
          for (final category in categories) ...[
            const SizedBox(width: AppSpacing.xs),
            _DimChip(
              chipKey: Key(
                'catalogCategoryChip_${slugify(category, emptyFallback: '')!}',
              ),
              label: category,
              count: categoryCounts[category] ?? 0,
              selected: selectedCategory == category,
              onTap: () => onSelect(category),
            ),
          ],
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Pinned filter bar
// ---------------------------------------------------------------------------

class _PinnedHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double height;
  final Widget child;

  const _PinnedHeaderDelegate({required this.height, required this.child});

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_PinnedHeaderDelegate oldDelegate) {
    return height != oldDelegate.height || child != oldDelegate.child;
  }
}

class _FocusableTapRegion extends StatefulWidget {
  final Key? regionKey;
  final VoidCallback onActivate;
  final BorderRadius borderRadius;
  final Widget child;

  const _FocusableTapRegion({
    this.regionKey,
    required this.onActivate,
    required this.borderRadius,
    required this.child,
  });

  @override
  State<_FocusableTapRegion> createState() => _FocusableTapRegionState();
}

class _FocusableTapRegionState extends State<_FocusableTapRegion> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return FocusableActionDetector(
      key: widget.regionKey,
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
      },
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            widget.onActivate();
            return null;
          },
        ),
      },
      onShowFocusHighlight: (isFocused) {
        if (_isFocused == isFocused) return;
        setState(() => _isFocused = isFocused);
      },
      child: AnimatedContainer(
        duration: MediaQuery.disableAnimationsOf(context) ||
                (context.read<AccessibilityService?>()?.reducedMotionEnabled ??
                    false)
            ? Duration.zero
            : AppAnimations.fast,
        foregroundDecoration: _isFocused
            ? BoxDecoration(
                borderRadius: widget.borderRadius,
                border: Border.all(color: AppColors.primary, width: 2),
              )
            : null,
        child: widget.child,
      ),
    );
  }
}

class _SimpleIconButton extends StatelessWidget {
  final Key? buttonKey;
  final IconData icon;
  final String semanticLabel;
  final bool isActive;
  final VoidCallback onTap;

  const _SimpleIconButton({
    this.buttonKey,
    required this.icon,
    required this.semanticLabel,
    this.isActive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isActive,
      label: semanticLabel,
      child: _FocusableTapRegion(
        regionKey: buttonKey,
        onActivate: onTap,
        borderRadius: BorderRadius.circular(12),
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: AppAnimations.fast,
            width: 48,
            height: 48,
            alignment: Alignment.center,
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
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Dimension filter chip - pill style
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
      child: _FocusableTapRegion(
        regionKey: chipKey,
        onActivate: onTap,
        borderRadius: BorderRadius.circular(24),
        child: PressableScale(
          onTap: onTap,
          builder: (isPressed) => AnimatedContainer(
            duration: AppAnimations.fast,
            constraints: const BoxConstraints(minHeight: 40),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: selected
                  ? LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withValues(alpha: 0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: selected ? null : AppColors.surface.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: selected
                    ? Colors.transparent
                    : AppColors.border.withValues(alpha: 0.4),
                width: 1,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (selected) ...[
                  const Icon(
                    Icons.check_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                ],
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 150),
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelSmall.copyWith(
                      color: selected ? Colors.white : AppColors.textSecondary,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Artwork-first grid tile with a readable caption and compact favorite action
// ---------------------------------------------------------------------------

class _ModuleGridTile extends StatefulWidget {
  final CatalogEntry entry;
  final AppLocalizations l10n;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;
  final bool isFavorite;
  final bool miniatures;
  final _GlobalShimmerController? shimmerController;

  const _ModuleGridTile({
    required this.entry,
    required this.l10n,
    required this.onTap,
    required this.onFavoriteToggle,
    required this.isFavorite,
    this.miniatures = false,
    this.shimmerController,
  });

  @override
  State<_ModuleGridTile> createState() => _ModuleGridTileState();
}

class _ModuleGridTileState extends State<_ModuleGridTile> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final is3D = widget.entry.module.dimension == FractalDimension.threeD;
    final dimensionLabel =
        is3D ? widget.l10n.dimension3d : widget.l10n.dimension2d;
    final name = widget.entry.module.displayName(widget.l10n);
    final presetCount = widget.entry.module.builtInPresets.length + 1;
    final isSpanish = Localizations.localeOf(context).languageCode == 'es';
    final presetLabel =
        isSpanish ? '$presetCount ajustes' : '$presetCount presets';
    final reduceMotion = MediaQuery.disableAnimationsOf(context) ||
        (context.read<AccessibilityService?>()?.reducedMotionEnabled ?? false);
    final highlighted = _isHovered || _isPressed;
    final thumbnailLayout = widget.miniatures
        ? CatalogThumbnailLayout.square
        : MediaQuery.sizeOf(context).width >= 1024
            ? CatalogThumbnailLayout.gridWide
            : CatalogThumbnailLayout.gridPortrait;

    return Semantics(
      label: widget.l10n.semanticFractalCard(name, dimensionLabel),
      button: true,
      child: _FocusableTapRegion(
        regionKey: Key('catalogModuleCard_${widget.entry.catalogId}'),
        onActivate: widget.onTap,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: GestureDetector(
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) => setState(() => _isPressed = false),
            onTapCancel: () => setState(() => _isPressed = false),
            onTap: widget.onTap,
            child: AnimatedContainer(
              duration: reduceMotion ? Duration.zero : AppAnimations.fast,
              decoration: BoxDecoration(
                color:
                    highlighted ? AppColors.surfaceElevated : AppColors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                border: Border.all(
                  color:
                      highlighted ? AppColors.primary : AppColors.borderLight,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        _PreviewThumbnail(
                          catalogId: widget.entry.catalogId,
                          module: widget.entry.module,
                          category: widget.entry.category,
                          layout: thumbnailLayout,
                          shimmerController: widget.shimmerController,
                        ),
                        if (widget.miniatures)
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(6, 16, 6, 6),
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Colors.transparent, Colors.black87],
                                ),
                              ),
                              child: Text(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.labelSmall.copyWith(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),
                        PositionedDirectional(
                          top: 0,
                          end: 0,
                          child: _CatalogFavoriteButton(
                            catalogId: widget.entry.catalogId,
                            isFavorite: widget.isFavorite,
                            onPressed: widget.onFavoriteToggle,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!widget.miniatures)
                    SizedBox(
                      key: Key('catalogCaption_${widget.entry.catalogId}'),
                      height: _catalogCaptionHeight(context),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Align(
                                alignment: AlignmentDirectional.topStart,
                                child: Text(
                                  name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.textPrimary,
                                    fontSize: 13,
                                    height: 1.25,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$dimensionLabel · $presetLabel',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                                height: 1.2,
                              ),
                            ),
                          ],
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

// Reserve two title lines at the user's actual text size, rather than forcing
// accessible text into a fixed-aspect tile and letting it cover the artwork.
double _catalogCaptionHeight(BuildContext context) {
  final scaler = MediaQuery.textScalerOf(context);
  return scaler.scale(13) * 1.25 * 2 + scaler.scale(11) * 1.2 + 24;
}

class _CatalogFavoriteButton extends StatelessWidget {
  final String catalogId;
  final bool isFavorite;
  final VoidCallback onPressed;

  const _CatalogFavoriteButton({
    required this.catalogId,
    required this.isFavorite,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isSpanish = Localizations.localeOf(context).languageCode == 'es';
    final label = isFavorite
        ? (isSpanish ? 'Quitar de favoritos' : 'Remove from favorites')
        : (isSpanish ? 'Añadir a favoritos' : 'Add to favorites');
    return Semantics(
      toggled: isFavorite,
      child: IconButton(
        key: Key('catalogFavorite_$catalogId'),
        tooltip: label,
        onPressed: onPressed,
        constraints: const BoxConstraints.tightFor(width: 48, height: 48),
        padding: const EdgeInsets.all(8),
        style: IconButton.styleFrom(
          backgroundColor: Colors.transparent,
          minimumSize: const Size.square(48),
          maximumSize: const Size.square(48),
          padding: const EdgeInsets.all(8),
          tapTargetSize: MaterialTapTargetSize.padded,
          visualDensity: VisualDensity.standard,
        ),
        icon: Container(
          key: Key('catalogFavoriteVisual_$catalogId'),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xE6101018),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white24),
          ),
          child: Icon(
            isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
            size: 18,
            color: isFavorite ? const Color(0xFFFFD166) : Colors.white,
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
              const SizedBox(height: AppSpacing.lg),
              TextButton.icon(
                key: const Key('catalogClearSearchButton'),
                onPressed: onClear,
                icon: const Icon(Icons.close_rounded, size: 18),
                label: Text(
                  query.isNotEmpty
                      ? l10n.actionClearSearch
                      : l10n.catalogClearFilters,
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                ),
              ),
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
  final VoidCallback onFavoriteToggle;
  final bool isFavorite;
  final AppLocalizations l10n;
  final _GlobalShimmerController? shimmerController;

  const _ModuleCard({
    required this.entry,
    required this.onTap,
    required this.onFavoriteToggle,
    required this.isFavorite,
    required this.l10n,
    this.shimmerController,
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
    // See the sibling card: localized via the existing key rather than built
    // inline in English.
    final semanticLabel = widget.l10n.semanticFractalCard(name, dimensionLabel);

    final reduceMotion = MediaQuery.of(context).disableAnimations ||
        (context.read<AccessibilityService?>()?.reducedMotionEnabled ?? false);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Semantics(
        label: semanticLabel,
        button: true,
        child: _FocusableTapRegion(
          regionKey: Key('catalogModuleCard_${widget.entry.catalogId}'),
          onActivate: widget.onTap,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          child: GestureDetector(
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
                ? _buildCardContent(dimensionLabel)
                : ScaleTransition(
                    scale: _scaleAnimation,
                    child: _buildCardContent(dimensionLabel),
                  ),
          ),
        ),
      ),
    );
  }

  String _mathSummary() {
    final module = widget.entry.module;
    final params = module.parameters.take(3).map((param) {
      final value = param.defaultValue;
      return '${param.label(widget.l10n)} $value';
    }).join(', ');
    final presetCount = module.builtInPresets.length + 1;
    if (params.isEmpty) return '$presetCount presets';
    return '${module.parameters.length} params: $params · $presetCount presets';
  }

  Widget _buildCardContent(String dimensionLabel) {
    return AnimatedContainer(
      duration: AppAnimations.fast,
      decoration: BoxDecoration(
        color: _isPressed ? AppColors.surfaceElevated : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(
          color: _isPressed
              ? AppColors.primary.withValues(alpha: 0.45)
              : AppColors.borderLight.withValues(alpha: 0.36),
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
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final showMathInfo = constraints.maxWidth >= 360;
            final thumbnailSize = constraints.maxWidth >= 420 ? 112.0 : 88.0;

            return Row(
              children: [
                SizedBox(
                  width: thumbnailSize,
                  height: thumbnailSize,
                  child: _PreviewThumbnail(
                    catalogId: widget.entry.catalogId,
                    module: widget.entry.module,
                    category: widget.entry.category,
                    layout: CatalogThumbnailLayout.square,
                    shimmerController: widget.shimmerController,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.entry.module.displayName(widget.l10n),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$dimensionLabel / ${widget.entry.category}',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                      if (showMathInfo) ...[
                        const SizedBox(height: 4),
                        Text(
                          _mathSummary(),
                          maxLines: constraints.maxWidth >= 520 ? 2 : 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  key: Key('catalogFavorite_${widget.entry.catalogId}'),
                  tooltip: widget.isFavorite
                      ? 'Remove from favorites'
                      : 'Add to favorites',
                  onPressed: widget.onFavoriteToggle,
                  icon: Icon(
                    widget.isFavorite
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: widget.isFavorite
                        ? AppColors.primary
                        : AppColors.textMuted,
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
            );
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Preview thumbnail with shimmer, improved badge, and category accent bar
// ---------------------------------------------------------------------------

@visibleForTesting
class CatalogRuntimeThumbnailCache {
  static final Set<String> _readyCatalogIds = <String>{};

  const CatalogRuntimeThumbnailCache._();

  static bool isReady(String catalogId) => _readyCatalogIds.contains(catalogId);

  static void markReady(String catalogId) => _readyCatalogIds.add(catalogId);

  static int get readyCountForTesting => _readyCatalogIds.length;

  static void setManifestForTesting(Set<String> ids) {
    _PreviewThumbnail._cachedThumbnailAssetIds = ids;
    _PreviewThumbnail._thumbnailAssetIds = Future.value(ids);
  }

  static void clearForTesting() {
    _readyCatalogIds.clear();
    // One hook keeps the whole runtime-thumbnail pipeline isolated between
    // tests: ready marks, cached pixels, and queued render slots.
    CatalogThumbnailCache.clearForTesting();
    CatalogThumbnailRenderGate.resetForTesting();
  }
}

class _PreviewThumbnail extends StatefulWidget {
  static const bool _useRuntimeThumbnails = bool.fromEnvironment(
    'RUNTIME_CATALOG_THUMBNAILS',
    defaultValue: true,
  );
  static const bool _forceRuntimeThumbnailsInTests = bool.fromEnvironment(
    'FORCE_RUNTIME_CATALOG_THUMBNAILS',
    defaultValue: false,
  );
  static Set<String>? _cachedThumbnailAssetIds;
  static Future<Set<String>> _thumbnailAssetIds = _loadThumbnailAssetIds();

  static Future<Set<String>> _loadThumbnailAssetIds() =>
      loadCatalogThumbnailAssetIds().then((ids) {
        _cachedThumbnailAssetIds = ids;
        return ids;
      });

  static void beginCatalogSession() {
    CatalogThumbnailTelemetry.instance.beginSession();
    _cachedThumbnailAssetIds = null;
    _thumbnailAssetIds = _loadThumbnailAssetIds();
  }

  final String catalogId;
  final FractalModule module;
  final String category;
  final CatalogThumbnailLayout layout;
  final _GlobalShimmerController? shimmerController;

  const _PreviewThumbnail({
    required this.catalogId,
    required this.module,
    required this.category,
    required this.layout,
    this.shimmerController,
  });

  @override
  State<_PreviewThumbnail> createState() => _PreviewThumbnailState();
}

class _PreviewThumbnailState extends State<_PreviewThumbnail>
    with SingleTickerProviderStateMixin {
  late final AnimationController _localShimmerController;
  Timer? _fallbackTimer;
  bool _imageLoaded = false;
  bool _imageError = false;
  bool _runtimePreviewEnabled = false;
  Uint8List? _cachedPreviewBytes;
  bool _cacheLoadStarted = false;

  /// Deterministic cache key for this entry's rendered pixels.
  String get _thumbnailSignature =>
      CatalogThumbnailCache.renderSignatureForModule(
        widget.catalogId,
        widget.module,
        layout: widget.layout,
      );

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
    // Force show image or fallback after timeout - prevents infinite gray in release.
    // Widget tests should settle deterministically instead of waiting on preview timeouts.
    if (!RuntimeModeService.isAutomatedTest) {
      _fallbackTimer = Timer(const Duration(seconds: 3), () {
        if (mounted && !_imageLoaded && !_imageError) {
          setState(() => _imageError = true);
        }
      });
    }
    _maybeLoadCachedPreview();
    if (!CatalogThumbnailCache.usesPersistentStorage &&
        _cachedPreviewBytes == null) {
      _scheduleRuntimePreview();
    }
  }

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    // Only dispose local controller, not the global one
    if (widget.shimmerController == null) {
      _localShimmerController.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(_PreviewThumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.catalogId != widget.catalogId ||
        oldWidget.layout != widget.layout) {
      _imageLoaded = false;
      _imageError = false;
      _runtimePreviewEnabled = false;
      _cachedPreviewBytes = null;
      _cacheLoadStarted = false;
      _maybeLoadCachedPreview();
      if (!CatalogThumbnailCache.usesPersistentStorage &&
          _cachedPreviewBytes == null) {
        _scheduleRuntimePreview();
      }
    }
  }

  void _scheduleRuntimePreview({bool notify = false}) {
    if (!_PreviewThumbnail._useRuntimeThumbnails ||
        (RuntimeModeService.isAutomatedTest &&
            !_PreviewThumbnail._forceRuntimeThumbnailsInTests)) {
      _runtimePreviewEnabled = false;
      return;
    }
    if (CatalogRuntimeThumbnailCache.isReady(widget.catalogId)) {
      _enableRuntimePreview(notify: notify);
      return;
    }

    // Live-render concurrency is bounded by CatalogThumbnailRenderGate inside
    // each runtime thumbnail, so every visible tile can request its preview
    // right away: the gate queues renderers instead of staggering blind
    // timers, and a tile renders as soon as a slot frees.
    _enableRuntimePreview(notify: notify);
  }

  void _enableRuntimePreview({bool notify = true}) {
    CatalogRuntimeThumbnailCache.markReady(widget.catalogId);
    if (_runtimePreviewEnabled) return;
    if (notify && mounted) {
      setState(() => _runtimePreviewEnabled = true);
    } else {
      _runtimePreviewEnabled = true;
    }
  }

  /// Loads a previously-rendered thumbnail from the in-memory cache (instant)
  /// or the on-disk cache (second+ launch), so a reused tile does not re-render
  /// on the GPU. Only the first cache miss falls through to a live render.
  void _maybeLoadCachedPreview() {
    if (_cacheLoadStarted) return;
    _cacheLoadStarted = true;

    final signature = _thumbnailSignature;
    final mem = CatalogThumbnailCache.inMemory(signature);
    if (mem != null) {
      CatalogThumbnailTelemetry.instance
          .recordCacheLookup(signature, hit: true);
      CatalogThumbnailTelemetry.instance.recordDisplayed(
        signature,
        source: CatalogThumbnailSource.memoryCache,
      );
      _cachedPreviewBytes = mem;
      return;
    }

    if (!CatalogThumbnailCache.usesPersistentStorage) {
      CatalogThumbnailTelemetry.instance
          .recordCacheLookup(signature, hit: false);
      return;
    }

    // Capture the signature at request time: the grid recycles elements, so
    // this state may be showing a different module by the time the disk read
    // resolves. Storing under the *current* signature would poison the cache
    // with another module's pixels.
    unawaited(_loadPersistentPreview(signature));
  }

  Future<void> _loadPersistentPreview(String signature) async {
    try {
      final bytes = await CatalogThumbnailCache.diskBytes(signature)
          .timeout(const Duration(milliseconds: 250));
      if (!mounted || signature != _thumbnailSignature) return;
      if (bytes != null) {
        CatalogThumbnailTelemetry.instance
            .recordCacheLookup(signature, hit: true);
        CatalogThumbnailTelemetry.instance.recordDisplayed(
          signature,
          source: CatalogThumbnailSource.diskCache,
        );
        // Promote to the in-memory cache for the rest of the session.
        unawaited(CatalogThumbnailCache.store(signature, bytes));
        setState(() => _cachedPreviewBytes = bytes);
        return;
      }
    } catch (_) {
      if (!mounted || signature != _thumbnailSignature) return;
    }

    CatalogThumbnailTelemetry.instance.recordCacheLookup(signature, hit: false);
    // Only a native cache miss/timeout reaches the GPU. Warm cache hits avoid
    // creating a controller, loading a shader, or taking a render-gate slot.
    _scheduleRuntimePreview(notify: true);
  }

  void _markImageLoaded() {
    if (_imageLoaded) return;
    if (!mounted) return;
    CatalogThumbnailTelemetry.instance.recordDisplayed(
      _thumbnailSignature,
      source: CatalogThumbnailSource.asset,
    );
    setState(() => _imageLoaded = true);
  }

  /// Called once a runtime thumbnail has finished its first paint. The child
  /// has already cached the PNG bytes under its own render signature; the
  /// parent only swaps the live renderer for the cached image, which lets the
  /// child (and its GPU renderer) be disposed.
  void _onRuntimePreviewRendered(String signature, Uint8List bytes) {
    if (signature != _thumbnailSignature) return;
    if (!mounted) return;
    setState(() => _cachedPreviewBytes = bytes);
  }

  void _discardCachedPreview(String signature) {
    if (!mounted || signature != _thumbnailSignature) return;
    unawaited(CatalogThumbnailCache.evict(signature));
    setState(() => _cachedPreviewBytes = null);
  }

  void _markImageError() {
    if (_imageError) return;
    if (!mounted) return;
    setState(() => _imageError = true);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Set<String>>(
      future: _PreviewThumbnail._thumbnailAssetIds,
      initialData: _PreviewThumbnail._cachedThumbnailAssetIds,
      builder: (context, snapshot) {
        final thumbnail = CatalogThumbnailAvailability.fromCatalogId(
          catalogId: widget.catalogId,
          availableThumbnailIds: snapshot.data,
          manifestFailed: snapshot.hasError,
          imageLoaded: _imageLoaded,
          imageError: _imageError,
        );
        final isApproximate = thumbnail.isApproximatePreview;

        // Serve previously-rendered pixels (in-memory or on-disk) instead of
        // re-rendering on the GPU: a tile that was already rendered stays
        // instant across scroll-back, filters, and second+ launches.
        final cachedBytes = _cachedPreviewBytes;
        if (cachedBytes != null) {
          final signature = _thumbnailSignature;
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(
              cachedBytes,
              key: Key('catalogCachedThumbnail_${widget.catalogId}'),
              fit: BoxFit.cover,
              gaplessPlayback: true,
              filterQuality: FilterQuality.high,
              width: 256,
              height: 256,
              cacheWidth: CatalogThumbnailCache.targetWidth,
              errorBuilder: (context, error, stackTrace) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _discardCachedPreview(signature);
                });
                return _GradientFallback(
                  catalogId: widget.catalogId,
                  category: widget.category,
                );
              },
            ),
          );
        }

        if (_runtimePreviewEnabled && thumbnail.showsFallbackPreview) {
          return _RuntimePreviewThumbnail(
            // Keyed so a recycled tile never reuses another module's render
            // state: the capture below stores under the signature the child
            // was built with.
            key: ValueKey('runtimePreview_$_thumbnailSignature'),
            catalogId: widget.catalogId,
            module: widget.module,
            category: widget.category,
            signature: _thumbnailSignature,
            onRendered: _onRuntimePreviewRendered,
          );
        }

        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Show shimmer while loading OR show gradient fallback on error.
              if (thumbnail.showsLoadingPlaceholder)
                _ShimmerSkeleton(controller: _localShimmerController)
              else if (thumbnail.showsFallbackPreview)
                _GradientFallback(
                  catalogId: widget.catalogId,
                  category: widget.category,
                ),

              // Only load images that are present in the asset manifest. This
              // avoids browser-console 404s for entries that use fallbacks.
              if (thumbnail.shouldLoadImage)
                Image.asset(
                  thumbnail.assetPath,
                  width: 256,
                  height: 256,
                  cacheWidth: 256,
                  cacheHeight: 256,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.medium,
                  gaplessPlayback: true,
                  frameBuilder:
                      (context, child, frame, wasSynchronouslyLoaded) {
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
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _markImageError();
                    });
                    return const SizedBox.shrink();
                  },
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
      },
    );
  }
}

class _RuntimePreviewThumbnail extends StatefulWidget {
  final String catalogId;
  final FractalModule module;
  final String category;

  /// Render signature this instance was built with. Captured pixels are
  /// always cached under this key, even if the tile is recycled mid-render.
  final String signature;

  /// Reports the PNG bytes of the first fully-painted frame. The parent swaps
  /// this live GPU render for the cached image, disposing the renderer.
  final void Function(String signature, Uint8List png) onRendered;

  const _RuntimePreviewThumbnail({
    super.key,
    required this.catalogId,
    required this.module,
    required this.category,
    required this.signature,
    required this.onRendered,
  });

  @override
  State<_RuntimePreviewThumbnail> createState() =>
      _RuntimePreviewThumbnailState();
}

class _RuntimePreviewThumbnailState extends State<_RuntimePreviewThumbnail> {
  final GlobalKey _tileKey = GlobalKey();
  final GlobalKey _captureKey = GlobalKey();
  bool _slotAcquirePending = false;
  bool _slotAcquired = false;
  bool _slotHeld = false;
  bool _reported = false;
  Timer? _captureTimeoutTimer;
  Timer? _captureRetryTimer;
  Timer? _webSlotReleaseTimer;
  final Stopwatch _readinessWait = Stopwatch();
  static const Duration _webCompileSlotHold = Duration(milliseconds: 750);

  @override
  void initState() {
    super.initState();
    // Slivers also build cache-extent children outside the viewport. Only
    // visible tiles may join the render queue; otherwise those hidden children
    // can occupy every bounded-concurrency slot and starve a rapid scroll.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _acquireSlotWhenVisible(),
    );
  }

  bool _isTileVisible() {
    if (!mounted) return false;
    final tile = _tileKey.currentContext?.findRenderObject();
    if (tile is! RenderBox || !tile.attached || !tile.hasSize) return false;
    final screenBounds = Offset.zero & MediaQuery.sizeOf(context);
    final tileBounds = tile.localToGlobal(Offset.zero) & tile.size;
    return tileBounds.overlaps(screenBounds);
  }

  void _scheduleVisibilityCheck() {
    if (_reported || !mounted) return;
    _captureRetryTimer?.cancel();
    _captureRetryTimer = Timer(
      CatalogThumbnailCapturePolicy.retryInterval,
      _acquireSlotWhenVisible,
    );
  }

  void _acquireSlotWhenVisible() {
    if (_reported || !mounted || _slotHeld || _slotAcquirePending) return;
    if (!_isTileVisible()) {
      _scheduleVisibilityCheck();
      return;
    }
    CatalogThumbnailTelemetry.instance
        .recordVisibleRenderQueued(widget.signature);
    _slotAcquirePending = true;
    CatalogThumbnailRenderGate.acquire().then((_) {
      _slotAcquirePending = false;
      _slotHeld = true;
      if (!mounted) {
        _releaseSlot();
        return;
      }
      // The tile can leave the viewport while waiting behind other renderers.
      // Return that slot immediately instead of mounting hidden GPU work.
      if (!_isTileVisible()) {
        CatalogThumbnailTelemetry.instance.recordNoLongerVisible(
          widget.signature,
        );
        _releaseSlot();
        _scheduleVisibilityCheck();
        return;
      }
      setState(() => _slotAcquired = true);
      if (kIsWeb) {
        // WebGL readback through RenderRepaintBoundary.toImage can block the
        // browser's main thread indefinitely. Keep the static live render, but
        // release the gate after a short compile window so later tiles render.
        _reported = true;
        _webSlotReleaseTimer = Timer(_webCompileSlotHold, _releaseSlot);
        return;
      }
      _readinessWait
        ..reset()
        ..start();
      // Capture the first fully-painted frame for the native cache.
      WidgetsBinding.instance.addPostFrameCallback((_) => _captureFrame());
    });
  }

  void _releaseSlot() {
    if (!_slotHeld) return;
    _slotHeld = false;
    CatalogThumbnailRenderGate.release();
  }

  @override
  void dispose() {
    CatalogThumbnailTelemetry.instance.recordNoLongerVisible(widget.signature);
    _captureTimeoutTimer?.cancel();
    _captureRetryTimer?.cancel();
    _webSlotReleaseTimer?.cancel();
    // No-op while still queued for a slot; the acquire completion releases a
    // handed-over slot instead, passing it to the next waiter.
    _releaseSlot();
    super.dispose();
  }

  void _releaseAfterReplacementFrame({bool retryWhenVisible = false}) {
    // Keep the slot until the parent has replaced this live renderer (or this
    // widget has switched back to its cheap fallback), so the gate continues
    // to bound the number of mounted GPU renderers rather than only captures.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _releaseSlot();
      if (retryWhenVisible) _scheduleVisibilityCheck();
    });
  }

  void _yieldSlotUntilVisible() {
    if (_reported || !mounted) return;
    CatalogThumbnailTelemetry.instance.recordNoLongerVisible(widget.signature);
    _readinessWait.stop();
    setState(() => _slotAcquired = false);
    _releaseAfterReplacementFrame(retryWhenVisible: true);
  }

  void _abandonCapture(String reason) {
    if (_reported || !mounted) return;
    CatalogThumbnailTelemetry.instance.recordRenderFailure(
      widget.signature,
      reason: reason,
    );
    _reported = true;
    setState(() => _slotAcquired = false);
    _releaseAfterReplacementFrame();
  }

  void _retryOrAbandonCapture({
    bool enforceReadinessTimeout = true,
    String terminalReason = 'readiness_timeout',
  }) {
    if (_reported || !mounted) return;
    if (enforceReadinessTimeout &&
        CatalogThumbnailCapturePolicy.readinessExpired(
          _readinessWait.elapsed,
        )) {
      _abandonCapture(terminalReason);
      return;
    }
    _captureRetryTimer?.cancel();
    _captureRetryTimer = Timer(
      CatalogThumbnailCapturePolicy.retryInterval,
      () {
        if (!mounted || _reported) return;
        WidgetsBinding.instance.addPostFrameCallback((_) => _captureFrame());
        WidgetsBinding.instance.scheduleFrame();
      },
    );
  }

  static Future<Uint8List?> _capturePng(
    RenderRepaintBoundary boundary,
    double pixelRatio,
  ) async {
    final image = await boundary.toImage(pixelRatio: pixelRatio);
    try {
      return await CatalogThumbnailCache.encodePng(image);
    } finally {
      image.dispose();
    }
  }

  Future<Uint8List?> _capturePngWithTimeout(
    RenderRepaintBoundary boundary,
    double pixelRatio,
  ) {
    final result = Completer<Uint8List?>();
    final capture = _capturePng(boundary, pixelRatio);
    _captureTimeoutTimer?.cancel();
    _captureTimeoutTimer =
        Timer(CatalogThumbnailCapturePolicy.readbackTimeout, () {
      if (!result.isCompleted) {
        result.completeError(
          TimeoutException('Catalog thumbnail capture timed out'),
        );
      }
    });
    capture.then<void>(
      (png) {
        if (!result.isCompleted) result.complete(png);
      },
      onError: (Object error, StackTrace stack) {
        if (!result.isCompleted) result.completeError(error, stack);
      },
    ).whenComplete(() {
      if (!result.isCompleted) return;
      _captureTimeoutTimer?.cancel();
      _captureTimeoutTimer = null;
    });
    return result.future;
  }

  Future<void> _captureFrame() async {
    if (_reported || !mounted) return;
    if (!_isTileVisible()) {
      // A rapid scroll can move a renderer off-screen while its shader is
      // compiling. Yield immediately so newly visible tiles get the slot, then
      // reacquire if this tile comes back into view.
      _yieldSlotUntilVisible();
      return;
    }
    final boundary = _captureKey.currentContext?.findRenderObject();
    if (boundary is! RenderRepaintBoundary ||
        !boundary.attached ||
        !boundary.hasSize) {
      // The renderer may still be compiling its shader. Retry on a bounded
      // timer so high frame rates cannot exhaust the readiness budget before
      // Android has had time to create the capture boundary.
      _retryOrAbandonCapture();
      return;
    }
    try {
      // Capture at a bounded resolution: enough for crisp display at any tile
      // size without writing oversized PNGs to the disk cache.
      final ratio = (CatalogThumbnailCache.targetWidth / boundary.size.width)
          .clamp(1.0, 3.0);
      final png = await _capturePngWithTimeout(boundary, ratio);
      if (png == null) {
        _retryOrAbandonCapture(terminalReason: 'empty_readback');
        return;
      }
      _reported = true;
      CatalogThumbnailTelemetry.instance.recordDisplayed(
        widget.signature,
        source: CatalogThumbnailSource.render,
      );
      // Memory is populated synchronously inside store(). Disk persistence is
      // best-effort and must not keep a scarce live-render slot occupied.
      unawaited(CatalogThumbnailCache.store(widget.signature, png));
      if (mounted) {
        widget.onRendered(widget.signature, png);
        _releaseAfterReplacementFrame();
      }
    } on TimeoutException {
      // Some platform readbacks never complete. Stop spending the scarce slot
      // on this tile so the rest of the visible catalog can keep progressing.
      _abandonCapture('readback_timeout');
    } catch (_) {
      // A failed readback must retry or release its slot; swallowing the error
      // here used to leave all later catalog thumbnails queued forever.
      _retryOrAbandonCapture(terminalReason: 'readback_error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: Key('catalogRuntimeThumbnail_${widget.catalogId}'),
      child: ClipRRect(
        key: _tileKey,
        borderRadius: BorderRadius.circular(12),
        // Until a concurrency slot frees up, only the cheap gradient shows.
        child: _slotAcquired
            ? Stack(
                fit: StackFit.expand,
                children: [
                  _GradientFallback(
                    catalogId: widget.catalogId,
                    category: widget.category,
                  ),
                  ChangeNotifierProvider<FractalController>(
                    key: ValueKey('runtimeThumb_${widget.catalogId}'),
                    create: (context) => _thumbnailController(
                        context, widget.catalogId, widget.module),
                    child: IgnorePointer(
                      child: FractalRenderer(
                        boundaryKey: _captureKey,
                        gesturesEnabled: false,
                        animationEnabled: false,
                        showRendererIndicator: false,
                      ),
                    ),
                  ),
                ],
              )
            : _GradientFallback(
                catalogId: widget.catalogId,
                category: widget.category,
              ),
      ),
    );
  }

  static FractalController _thumbnailController(
    BuildContext context,
    String catalogId,
    FractalModule module,
  ) {
    final controller = FractalController(context.read<ModuleRegistry>());
    controller.selectModule(module, animate: false);
    final maxIterations = CatalogThumbnailCache.maxIterationsFor(catalogId);
    final iterations = controller.params['iterations'];
    if (iterations is int && iterations > maxIterations) {
      controller.updateParam('iterations', maxIterations);
    } else if (iterations is double && iterations > maxIterations) {
      controller.updateParam('iterations', maxIterations.toDouble());
    }

    const maxColorCount = CatalogThumbnailCache.maxColorCount;
    final colorCount = controller.params['colorCount'];
    if (colorCount is int && colorCount > maxColorCount) {
      controller.updateParam('colorCount', maxColorCount);
    } else if (colorCount is double && colorCount > maxColorCount) {
      controller.updateParam('colorCount', maxColorCount.toDouble());
    }

    final paletteIndex = _thumbnailPaletteIndex(catalogId, module);
    if (paletteIndex != null) {
      controller.updateParam('colorScheme', paletteIndex);
    }
    final viewOverride = CatalogThumbnailCache.viewOverrideFor(catalogId);
    if (viewOverride != null) {
      final pan = controller.view.pan
        ..setValues(viewOverride.centerX, viewOverride.centerY);
      controller.updateView(
        controller.view.copyWith(pan: pan, zoom: viewOverride.zoom),
      );
    }
    return controller;
  }

  static int? _thumbnailPaletteIndex(String catalogId, FractalModule module) {
    for (final param in module.parameters) {
      if (param.id != 'colorScheme') continue;
      final min = param.min.ceil();
      final max = param.max.floor();
      final range = (max - min + 1).clamp(1, CommonFractalParams.paletteCount);
      return min + (_stableCatalogHash(catalogId) % range);
    }
    return null;
  }
}

int _stableCatalogHash(String value) {
  var hash = 0x811C9DC5;
  for (final unit in value.codeUnits) {
    hash ^= unit;
    hash = (hash * 0x01000193) & 0x7FFFFFFF;
  }
  return hash;
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

part of '../fractal_catalog_screen.dart';

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
// Category filter rail
// ---------------------------------------------------------------------------

class _CategoryFilterRail extends StatelessWidget {
  final String allCategoriesLabel;
  final int totalCategoryCount;
  final List<String> categories;
  final Map<String, int> categoryCounts;
  final String? selectedCategory;
  final ValueChanged<String?> onSelect;

  const _CategoryFilterRail({
    required this.allCategoriesLabel,
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
        duration: AppAnimations.fast,
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
    final presetCount = widget.entry.module.builtInPresets.length + 1;
    final accentColor = _categoryAccentColor(widget.entry.category);

    return Semantics(
      label:
          '$name fractal, ${widget.entry.category}, $dimensionLabel, $presetCount presets. Double tap to open.',
      button: true,
      child: _FocusableTapRegion(
        regionKey: Key('catalogModuleCard_${widget.entry.catalogId}'),
        onActivate: widget.onTap,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        child: MouseRegion(
          onEnter: (_) => _setHighlight(true),
          onExit: (_) => _setHighlight(false),
          child: GestureDetector(
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
                    color: AppColors.surfaceElevated.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
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
                              module: widget.entry.module,
                              category: widget.entry.category,
                              shimmerController: widget.shimmerController,
                            ),
                            // Gradient overlay for text
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: Container(
                                padding:
                                    const EdgeInsets.fromLTRB(10, 26, 10, 10),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withValues(alpha: 0.55),
                                      Colors.black.withValues(alpha: 0.9),
                                    ],
                                  ),
                                ),
                                child: Text(
                                  name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.left,
                                  style: AppTypography.labelSmall.copyWith(
                                    color: Colors.white,
                                    fontSize: 12,
                                    height: 1.15,
                                    fontWeight: FontWeight.w700,
                                    shadows: const [
                                      Shadow(
                                        color: Colors.black87,
                                        blurRadius: 5,
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
  final AppLocalizations l10n;
  final _GlobalShimmerController? shimmerController;

  const _ModuleCard({
    required this.entry,
    required this.onTap,
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
    final presetCount = widget.entry.module.builtInPresets.length + 1;
    final semanticLabel =
        '$name fractal, ${widget.entry.category}, $dimensionLabel, $presetCount presets. Double tap to open.';

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
  return const Color(0xFF2980B9);
}

// ---------------------------------------------------------------------------
// Preview thumbnail with shimmer, improved badge, and category accent bar
// ---------------------------------------------------------------------------

class _PreviewThumbnail extends StatefulWidget {
  static const bool _useRuntimeThumbnails = bool.fromEnvironment(
    'RUNTIME_CATALOG_THUMBNAILS',
    defaultValue: true,
  );
  static const int _webImmediateRuntimeThumbnailSlots = 16;
  static int _webRuntimeThumbnailSlotsUsed = 0;

  final String catalogId;
  final FractalModule module;
  final String category;
  final _GlobalShimmerController? shimmerController;

  const _PreviewThumbnail({
    required this.catalogId,
    required this.module,
    required this.category,
    this.shimmerController,
  });

  @override
  State<_PreviewThumbnail> createState() => _PreviewThumbnailState();
}

class _PreviewThumbnailState extends State<_PreviewThumbnail>
    with SingleTickerProviderStateMixin {
  late final AnimationController _localShimmerController;
  late final Future<Set<String>> _thumbnailAssetIds;
  Timer? _fallbackTimer;
  Timer? _runtimePreviewTimer;
  bool _imageLoaded = false;
  bool _imageError = false;
  bool _runtimePreviewEnabled = false;

  @override
  void initState() {
    super.initState();
    _thumbnailAssetIds = loadCatalogThumbnailAssetIds();

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
    _scheduleRuntimePreview();
  }

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    _runtimePreviewTimer?.cancel();
    // Only dispose local controller, not the global one
    if (widget.shimmerController == null) {
      _localShimmerController.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(_PreviewThumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.catalogId != widget.catalogId) {
      _imageLoaded = false;
      _imageError = false;
      _scheduleRuntimePreview();
    }
  }

  void _scheduleRuntimePreview() {
    _runtimePreviewTimer?.cancel();
    if (!_PreviewThumbnail._useRuntimeThumbnails ||
        RuntimeModeService.isAutomatedTest) {
      _runtimePreviewEnabled = false;
      return;
    }
    if (!kIsWeb) {
      _runtimePreviewEnabled = true;
      return;
    }

    // Web: show the visible row quickly, then stagger the rest to avoid the
    // original 25-shader startup burst.
    if (_PreviewThumbnail._webRuntimeThumbnailSlotsUsed <
        _PreviewThumbnail._webImmediateRuntimeThumbnailSlots) {
      _PreviewThumbnail._webRuntimeThumbnailSlotsUsed++;
      _runtimePreviewEnabled = true;
      return;
    }
    _runtimePreviewEnabled = false;
    final staggerMs = widget.catalogId.hashCode.abs() % 2500;
    _runtimePreviewTimer = Timer(Duration(milliseconds: 1500 + staggerMs), () {
      if (mounted) setState(() => _runtimePreviewEnabled = true);
    });
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
    return FutureBuilder<Set<String>>(
      future: _thumbnailAssetIds,
      builder: (context, snapshot) {
        final thumbnail = CatalogThumbnailAvailability.fromCatalogId(
          catalogId: widget.catalogId,
          availableThumbnailIds: snapshot.data,
          manifestFailed: snapshot.hasError,
          imageLoaded: _imageLoaded,
          imageError: _imageError,
        );
        final isApproximate = thumbnail.isApproximatePreview;
        if (_runtimePreviewEnabled && thumbnail.showsFallbackPreview) {
          return _RuntimePreviewThumbnail(
            catalogId: widget.catalogId,
            module: widget.module,
            category: widget.category,
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

class _RuntimePreviewThumbnail extends StatelessWidget {
  final String catalogId;
  final FractalModule module;
  final String category;

  const _RuntimePreviewThumbnail({
    required this.catalogId,
    required this.module,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        fit: StackFit.expand,
        children: [
          _GradientFallback(catalogId: catalogId, category: category),
          ChangeNotifierProvider<FractalController>(
            key: ValueKey('runtimeThumb_$catalogId'),
            create: (context) => _thumbnailController(context, module),
            child: const IgnorePointer(
              child: RepaintBoundary(
                child: FractalRenderer(
                  gesturesEnabled: false,
                  animationEnabled: false,
                  showRendererIndicator: false,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static FractalController _thumbnailController(
    BuildContext context,
    FractalModule module,
  ) {
    final controller = FractalController(context.read<ModuleRegistry>());
    controller.selectModule(module, animate: false);
    final maxIterations = kIsWeb ? 32 : 96;
    final iterations = controller.params['iterations'];
    if (iterations is int && iterations > maxIterations) {
      controller.updateParam('iterations', maxIterations);
    } else if (iterations is double && iterations > maxIterations) {
      controller.updateParam('iterations', maxIterations.toDouble());
    }
    return controller;
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

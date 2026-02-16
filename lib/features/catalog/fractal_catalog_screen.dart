import 'dart:async';
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

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isSearchFocused = _focusNode.hasFocus);
    });
    _loadViewPreference();
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

  @override
  Widget build(BuildContext context) {
    final registry = context.read<ModuleRegistry>();
    final l10n = AppLocalizations.of(context)!;

    final query = _searchController.text.trim().toLowerCase();
    final catalog = CatalogRepository.fromRegistry(registry);
    final allEntries = catalog.entries.where((entry) {
      if (query.isEmpty) return true;
      final name = entry.module.displayName(l10n).toLowerCase();
      final matchesAlias =
          entry.aliases.any((a) => a.toLowerCase().contains(query));
      return name.contains(query) ||
          matchesAlias ||
          entry.catalogId.contains(query) ||
          entry.category.toLowerCase().contains(query);
    }).toList();

    final groupedEntries = <String, List<CatalogEntry>>{};
    for (final entry in allEntries) {
      groupedEntries.putIfAbsent(entry.category, () => []).add(entry);
    }

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
          hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
          prefixIcon: AnimatedContainer(
            duration: AppAnimations.fast,
            child: Icon(
              Icons.search_rounded,
              color: _isSearchFocused ? AppColors.primary : AppColors.textMuted,
            ),
          ),
          suffixIcon: AnimatedSwitcher(
            duration: AppAnimations.fast,
            child: _searchController.text.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
                    key: const ValueKey('clear'),
                    tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
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
    // Flatten grouped entries into a flat list of widgets for lazy building.
    final flatItems = <({String type, CatalogEntry? entry, String? title})>[];
    for (final section in groupedEntries.entries) {
      flatItems.add((type: 'header', entry: null, title: section.key));
      for (final entry in section.value) {
        flatItems.add((type: 'card', entry: entry, title: null));
      }
      flatItems.add((type: 'spacer', entry: null, title: null));
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
            return SectionHeader(title: item.title!);
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
            SectionHeader(title: section.key),
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
      child: InkWell(
        key: Key('catalogGridTile_${entry.catalogId}'),
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: _PreviewThumbnail(
                    catalogId: entry.catalogId,
                    is3D: is3D,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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

class _PreviewThumbnail extends StatelessWidget {
  final String catalogId;
  final bool is3D;
  final double? size;

  const _PreviewThumbnail({
    required this.catalogId,
    required this.is3D,
    this.size,
  });

  /// CPU thumbnail renderer implements only 8 fractal formulas.
  /// Others use Mandelbrot fallback (thumbnail approximate).
  bool _hasExactCpuThumbnail(String catalogId) {
    final id = catalogId.startsWith('core.') ? catalogId.substring(5) : catalogId;
    return const [
      'mandelbrot',
      'julia',
      'burning_ship',
      'celtic',
      'buffalo',
      'tricorn',
      'multibrot3',
      'phoenix',
    ].contains(id);
  }

  @override
  Widget build(BuildContext context) {
    // Strip 'core.' prefix to match thumbnail filenames (e.g. mandelbrot.png).
    final thumbId = catalogId.startsWith('core.') ? catalogId.substring(5) : catalogId;
    final thumbAsset = 'assets/catalog_thumbs/$thumbId.png';
    final isApproximate = !_hasExactCpuThumbnail(catalogId);

    return Container(
      width: size ?? double.infinity,
      height: size ?? double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              thumbAsset,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.low,
              errorBuilder: (context, error, stack) => _GradientFallback(catalogId: catalogId),
            ),
          ),
          Positioned(
            top: 6,
            right: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.35),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                is3D ? '3D' : '2D',
                style: AppTypography.labelSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          if (isApproximate)
            Positioned(
              bottom: 4,
              left: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
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

class _GradientFallback extends StatelessWidget {
  final String catalogId;
  const _GradientFallback({required this.catalogId});

  @override
  Widget build(BuildContext context) {
    final hash = catalogId.hashCode;
    final hueA = (hash.abs() % 360).toDouble();
    final hueB = ((hash.abs() ~/ 11) % 360).toDouble();
    final colorA = HSVColor.fromAHSV(1, hueA, 0.58, 0.92).toColor();
    final colorB = HSVColor.fromAHSV(1, hueB, 0.66, 0.78).toColor();
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colorA, colorB],
        ),
      ),
    );
  }
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
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        child: Row(
          children: [
            _PreviewThumbnail(
              catalogId: widget.entry.catalogId,
              is3D: is3D,
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

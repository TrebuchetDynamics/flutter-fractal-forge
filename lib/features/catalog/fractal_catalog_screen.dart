import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/services/accessibility_service.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/core/widgets/animated_widgets.dart';
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
  final _focusNode = FocusNode();
  Timer? _debounce;
  bool _isSearchFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isSearchFocused = _focusNode.hasFocus);
    });
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
    final allModules = registry.modules.where((module) {
      if (query.isEmpty) return true;
      final name = module.displayName(l10n).toLowerCase();
      return name.contains(query);
    }).toList();

    // Group by dimension
    final modules2D = allModules.where((m) => m.dimension == FractalDimension.twoD).toList();
    final modules3D = allModules.where((m) => m.dimension == FractalDimension.threeD).toList();

    return Column(
      children: [
        // Premium search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          child: AnimatedContainer(
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
          ),
        ),
        Expanded(
          child: allModules.isEmpty
              ? _EmptyState(
                  query: query,
                  l10n: l10n,
                  onClear: () {
                    _searchController.clear();
                    setState(() {});
                  },
                )
              : ListView(
                  padding: EdgeInsets.only(
                    left: AppSpacing.lg,
                    right: AppSpacing.lg,
                    top: AppSpacing.sm,
                    bottom: MediaQuery.of(context).padding.bottom + 100,
                  ),
                  children: [
                    if (modules3D.isNotEmpty) ...[
                      SectionHeader(title: l10n.fractalSection3d),
                      ...modules3D.asMap().entries.map((entry) {
                        return StaggeredItem(
                          index: entry.key,
                          child: _ModuleCard(
                            module: entry.value,
                            onTap: () => _openViewer(context, entry.value),
                            l10n: l10n,
                          ),
                        );
                      }),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                    if (modules2D.isNotEmpty) ...[
                      SectionHeader(title: l10n.fractalSection2d),
                      ...modules2D.asMap().entries.map((entry) {
                        return StaggeredItem(
                          index: entry.key + modules3D.length,
                          child: _ModuleCard(
                            module: entry.value,
                            onTap: () => _openViewer(context, entry.value),
                            l10n: l10n,
                          ),
                        );
                      }),
                    ],
                  ],
                ),
        ),
      ],
    );
  }

  void _openViewer(BuildContext context, FractalModule module) {
    final controller = context.read<FractalController>();
    controller.selectModule(module);
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ChangeNotifierProvider.value(
          value: controller,
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
                style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary),
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
  final FractalModule module;
  final VoidCallback onTap;
  final AppLocalizations l10n;

  const _ModuleCard({
    required this.module,
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
    final is3D = widget.module.dimension == FractalDimension.threeD;
    final dimensionLabel = is3D ? widget.l10n.dimension3d : widget.l10n.dimension2d;
    final name = widget.module.displayName(widget.l10n);
    final semanticLabel = widget.l10n.semanticFractalCard(name, dimensionLabel);
    
    // Check for reduced motion preference
    final reduceMotion = MediaQuery.of(context).disableAnimations ||
        (context.read<AccessibilityService?>()?.reducedMotionEnabled ?? false);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Semantics(
        label: semanticLabel,
        button: true,
        child: GestureDetector(
          key: Key('catalogModuleCard_${widget.module.id}'),
          onTapDown: reduceMotion ? null : (_) {
            setState(() => _isPressed = true);
            _controller.forward();
          },
          onTapUp: reduceMotion ? null : (_) {
            setState(() => _isPressed = false);
            _controller.reverse();
          },
          onTapCancel: reduceMotion ? null : () {
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
        color: _isPressed
            ? AppColors.surfaceElevated
            : AppColors.surface,
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
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            // Dimension indicator
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: is3D
                    ? AppColors.primaryGradient
                    : LinearGradient(
                        colors: [
                          AppColors.secondary.withOpacity(0.8),
                          AppColors.secondaryDark,
                        ],
                      ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  is3D ? '3D' : '2D',
                  style: AppTypography.labelLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.module.displayName(widget.l10n),
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
                color: _isPressed
                    ? AppColors.primary
                    : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

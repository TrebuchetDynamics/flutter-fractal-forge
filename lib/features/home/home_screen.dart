import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/features/catalog/fractal_catalog_screen.dart';
import 'package:flutter_fractals/features/ar/ar_overlay_screen.dart';
import 'package:flutter_fractals/features/renderer/providers/fractal_provider.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _index = 0;
  late final AnimationController _animController;

  late final FractalController _exploreController;
  late final FractalController _arController;

  @override
  void initState() {
    super.initState();
    final registry = context.read<ModuleRegistry>();
    // Keep controller state scoped per tab so AR-specific tweaks (quality presets,
    // transparent background) don't leak into the Explore/catalog/viewer flow.
    _exploreController = FractalController(registry);
    _arController = FractalController(registry);
    _animController = AnimationController(
      duration: AppAnimations.normal,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    _exploreController.dispose();
    _arController.dispose();
    super.dispose();
  }

  void _onTabChanged(int index) {
    if (index != _index) {
      setState(() => _index = index);
      _animController.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final body = AnimatedSwitcher(
      duration: AppAnimations.normal,
      switchInCurve: AppAnimations.defaultCurve,
      switchOutCurve: AppAnimations.defaultCurve,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.02),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: _index == 0
          ? ChangeNotifierProvider.value(
              key: const ValueKey('explore'),
              value: _exploreController,
              child: const FractalCatalogScreen(),
            )
          : ChangeNotifierProvider.value(
              key: const ValueKey('ar'),
              value: _arController,
              child: const ArOverlayScreen(),
            ),
    );

    return Scaffold(
      extendBody: true,
      appBar: _PremiumAppBar(
        title: _index == 0 ? l10n.catalogTitle : l10n.arTitle,
      ),
      body: body,
      bottomNavigationBar: _PremiumNavBar(
        currentIndex: _index,
        onTap: _onTabChanged,
        items: [
          _NavItem(icon: Icons.grid_view_rounded, label: l10n.tabExplore),
          _NavItem(icon: Icons.camera_rounded, label: l10n.tabAr),
        ],
      ),
    );
  }
}

class _PremiumAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const _PremiumAppBar({required this.title});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.85),
            border: Border(
              bottom: BorderSide(
                color: AppColors.border.withValues(alpha: 0.3),
              ),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              height: kToolbarHeight,
              child: Center(
                child: AnimatedSwitcher(
                  duration: AppAnimations.fast,
                  child: Text(
                    title,
                    key: ValueKey(title),
                    style: AppTypography.titleLarge,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem({required this.icon, required this.label});
}

class _PremiumNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<_NavItem> items;

  const _PremiumNavBar({
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.lg),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.xxl),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(AppSpacing.xxl),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.4),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(items.length, (index) {
                final item = items[index];
                final isSelected = index == currentIndex;
                return _NavBarItem(
                  icon: item.icon,
                  label: item.label,
                  isSelected: isSelected,
                  onTap: () => onTap(index),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_NavBarItem> createState() => _NavBarItemState();
}

class _NavBarItemState extends State<_NavBarItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.fast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
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
    final color = widget.isSelected ? AppColors.primary : AppColors.textMuted;

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: AppAnimations.normal,
                curve: AppAnimations.defaultCurve,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? AppColors.primary.withValues(alpha: 0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  widget.icon,
                  color: color,
                  size: 22,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: AppAnimations.normal,
                style: AppTypography.labelSmall.copyWith(
                  color: color,
                  fontWeight: widget.isSelected
                      ? FontWeight.w600
                      : FontWeight.w400,
                ),
                child: Text(widget.label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

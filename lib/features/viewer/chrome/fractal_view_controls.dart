import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_fractals/core/services/accessibility_service.dart';
import 'package:flutter_fractals/core/services/haptic_service.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/core/widgets/animated_widgets.dart';
import 'package:flutter_fractals/features/auto_explore/auto_explore.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';

class FractalViewControls extends StatelessWidget {
  final AnimationController fabController;
  final AutoExploreService? autoExploreService;
  final bool isExporting;
  final String backTooltip;
  final VoidCallback onGoBack;
  final VoidCallback onToggleFullscreen;
  final VoidCallback onOpenAutoExploreSettings;
  final VoidCallback onOpenRandomFractal;
  final VoidCallback onOpenControls;
  final VoidCallback onOpenExport;

  const FractalViewControls({
    super.key,
    required this.fabController,
    this.autoExploreService,
    required this.isExporting,
    required this.backTooltip,
    required this.onGoBack,
    required this.onToggleFullscreen,
    required this.onOpenAutoExploreSettings,
    required this.onOpenRandomFractal,
    required this.onOpenControls,
    required this.onOpenExport,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final screenHeight = MediaQuery.of(context).size.height;

    return FadeTransition(
      opacity: fabController,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.5, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: fabController,
          curve: AppAnimations.defaultCurve,
        )),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: screenHeight * 0.85),
          child: SingleChildScrollView(
            reverse: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButtonWidget(
                  icon: Icons.arrow_back_rounded,
                  tooltip: backTooltip,
                  onPressed: isExporting ? null : onGoBack,
                  delay: const Duration(milliseconds: 0),
                ),
                const SizedBox(height: AppSpacing.md),
                FloatingActionButtonWidget(
                  icon: Icons.fullscreen_rounded,
                  tooltip: l10n.tooltipFullscreen,
                  onPressed: isExporting ? null : onToggleFullscreen,
                  delay: const Duration(milliseconds: 60),
                ),
                const SizedBox(height: AppSpacing.md),
                // Auto-explore button
                if (autoExploreService != null)
                  ChangeNotifierProvider<AutoExploreService>.value(
                    value: autoExploreService!,
                    child: AutoExploreButton(
                      delay: const Duration(milliseconds: 90),
                      onLongPress:
                          isExporting ? null : onOpenAutoExploreSettings,
                    ),
                  ),
                if (autoExploreService != null)
                  const SizedBox(height: AppSpacing.md),
                // Keep the viewer uncluttered: only core actions here.
                FloatingActionButtonWidget(
                  key: const ValueKey('viewerControlsButton'),
                  icon: Icons.tune_rounded,
                  tooltip: l10n.tooltipOpenControls,
                  onPressed: isExporting ? null : onOpenControls,
                  delay: const Duration(milliseconds: 120),
                ),
                const SizedBox(height: AppSpacing.md),
                FloatingActionButtonWidget(
                  key: const ValueKey('viewerRandomButton'),
                  icon: Icons.shuffle_rounded,
                  tooltip: l10n.tooltipRandomFractal,
                  onPressed: isExporting ? null : onOpenRandomFractal,
                  isPrimary: true,
                  delay: const Duration(milliseconds: 135),
                ),
                const SizedBox(height: AppSpacing.md),
                FloatingActionButtonWidget(
                  key: const ValueKey('viewerExportButton'),
                  icon: Icons.download_rounded,
                  tooltip: l10n.tooltipExport,
                  onPressed: isExporting ? null : onOpenExport,
                  delay: const Duration(milliseconds: 180),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FloatingActionButtonWidget extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final Duration delay;

  const FloatingActionButtonWidget({
    super.key,
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.isPrimary = false,
    this.delay = Duration.zero,
  });

  @override
  State<FloatingActionButtonWidget> createState() =>
      _FloatingActionButtonWidgetState();
}

class _FloatingActionButtonWidgetState extends State<FloatingActionButtonWidget>
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
    // Check for reduced motion preference
    final reduceMotion = MediaQuery.of(context).disableAnimations ||
        (context.read<AccessibilityService?>()?.reducedMotionEnabled ?? false);

    return FadeIn(
      delay: reduceMotion ? Duration.zero : widget.delay,
      child: Semantics(
        label: widget.tooltip,
        button: true,
        enabled: widget.onPressed != null,
        child: Tooltip(
          message: widget.tooltip,
          child: GestureDetector(
            onTapDown: (widget.onPressed != null && !reduceMotion)
                ? (_) {
                    setState(() => _isPressed = true);
                    _controller.forward();
                    HapticService.medium();
                  }
                : null,
            onTapUp: (widget.onPressed != null && !reduceMotion)
                ? (_) {
                    setState(() => _isPressed = false);
                    _controller.reverse();
                  }
                : null,
            onTapCancel: (widget.onPressed != null && !reduceMotion)
                ? () {
                    setState(() => _isPressed = false);
                    _controller.reverse();
                  }
                : null,
            onTap: widget.onPressed,
            child: reduceMotion
                ? _buildButtonContent()
                : ScaleTransition(
                    scale: _scaleAnimation,
                    child: _buildButtonContent(),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonContent() {
    return AnimatedContainer(
      duration: AppAnimations.fast,
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        gradient: widget.isPrimary ? AppColors.primaryGradient : null,
        color: widget.isPrimary ? null : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: widget.isPrimary
            ? null
            : Border.all(
                color: _isPressed
                    ? AppColors.primary.withValues(alpha: 0.5)
                    : AppColors.border.withValues(alpha: 0.5),
              ),
        boxShadow: [
          BoxShadow(
            color: widget.isPrimary
                ? AppColors.primary.withValues(alpha: _isPressed ? 0.5 : 0.3)
                : Colors.black.withValues(alpha: 0.2),
            blurRadius: _isPressed ? 16 : 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        widget.icon,
        size: 22,
        color: widget.isPrimary
            ? Colors.white
            : (_isPressed ? AppColors.primary : AppColors.textSecondary),
      ),
    );
  }
}

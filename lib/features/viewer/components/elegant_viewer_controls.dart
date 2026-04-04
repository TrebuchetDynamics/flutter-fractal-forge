import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_fractals/core/services/accessibility_service.dart';
import 'package:flutter_fractals/core/services/haptic_service.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/core/widgets/glassmorphic_widgets.dart';
import 'package:flutter_fractals/features/auto_explore/auto_explore.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';

/// Compact, elegant control dock for the fractal viewer.
///
/// Features:
/// - Glassmorphic design with backdrop blur
/// - Collapsible sections for space efficiency
/// - Haptic feedback on interactions
/// - Smooth animations
/// - Accessible touch targets
class ElegantViewerControls extends StatelessWidget {
  final AnimationController animationController;
  final AutoExploreService? autoExploreService;
  final bool isExporting;
  final String backTooltip;
  final VoidCallback onGoBack;
  final VoidCallback onToggleFullscreen;
  final VoidCallback onOpenAutoExploreSettings;
  final VoidCallback onOpenControls;
  final VoidCallback onOpenExport;
  final VoidCallback onRandomFractal;

  const ElegantViewerControls({
    super.key,
    required this.animationController,
    this.autoExploreService,
    required this.isExporting,
    required this.backTooltip,
    required this.onGoBack,
    required this.onToggleFullscreen,
    required this.onOpenAutoExploreSettings,
    required this.onOpenControls,
    required this.onOpenExport,
    required this.onRandomFractal,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenHeight = MediaQuery.of(context).size.height;
    final reducedMotion = MediaQuery.of(context).disableAnimations ||
        (context.read<AccessibilityService?>()?.reducedMotionEnabled ?? false);

    return FadeTransition(
      opacity: animationController,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.3, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animationController,
          curve: AppAnimations.defaultCurve,
        )),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: screenHeight * 0.7),
          child: GlassmorphicContainer(
            borderRadius: 20,
            blurSigma: 20,
            opacity: 0.1,
            padding: const EdgeInsets.all(8),
            child: SingleChildScrollView(
              reverse: true,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Navigation group - compact
                  _ControlGroup(
                    children: [
                      _ElegantIconButton(
                        icon: Icons.arrow_back_rounded,
                        tooltip: backTooltip,
                        onTap: isExporting ? null : onGoBack,
                        delay: reducedMotion ? Duration.zero : Duration.zero,
                      ),
                      const SizedBox(height: 4),
                      _ElegantIconButton(
                        icon: Icons.fullscreen_rounded,
                        tooltip: l10n.tooltipFullscreen,
                        onTap: isExporting ? null : onToggleFullscreen,
                        delay: reducedMotion
                            ? Duration.zero
                            : AppAnimations.staggerDelay,
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Auto-explore button - if available
                  if (autoExploreService != null)
                    ChangeNotifierProvider<AutoExploreService>.value(
                      value: autoExploreService!,
                      child: _AutoExploreToggle(
                        delay: reducedMotion
                            ? Duration.zero
                            : AppAnimations.controlRevealDelay,
                        onLongPress:
                            isExporting ? null : onOpenAutoExploreSettings,
                      ),
                    ),

                  if (autoExploreService != null) const SizedBox(height: 8),

                  // Action group - compact
                  _ControlGroup(
                    children: [
                      _ElegantIconButton(
                        key: const ValueKey('viewerRandomFractalButton'),
                        icon: Icons.shuffle_rounded,
                        tooltip: l10n.tooltipRandomFractal,
                        onTap: isExporting ? null : onRandomFractal,
                        delay: reducedMotion
                            ? Duration.zero
                            : AppAnimations.viewerControlReveal1,
                      ),
                      const SizedBox(height: 4),
                      _ElegantIconButton(
                        key: const ValueKey('viewerExportButton'),
                        icon: Icons.share_rounded,
                        tooltip: l10n.tooltipShare,
                        onTap: isExporting ? null : onOpenExport,
                        delay: reducedMotion
                            ? Duration.zero
                            : AppAnimations.viewerControlReveal2,
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Primary control button - highlighted
                  _ElegantIconButton(
                    key: const ValueKey('viewerControlsButton'),
                    icon: Icons.tune_rounded,
                    tooltip: l10n.tooltipOpenControls,
                    onTap: isExporting ? null : onOpenControls,
                    isPrimary: true,
                    delay: reducedMotion ? Duration.zero : AppAnimations.fast,
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

/// A compact group of controls with subtle separation.
class _ControlGroup extends StatelessWidget {
  final List<Widget> children;

  const _ControlGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}

/// An elegant icon button with subtle animations and haptic feedback.
class _ElegantIconButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final bool isPrimary;
  final Duration delay;

  const _ElegantIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    this.onTap,
    this.isPrimary = false,
    this.delay = Duration.zero,
  });

  @override
  State<_ElegantIconButton> createState() => _ElegantIconButtonState();
}

class _ElegantIconButtonState extends State<_ElegantIconButton>
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
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    // Start animation after delay
    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      setState(() => _isPressed = true);
      HapticService.light();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    // WCAG 2.2 minimum touch target: 48x48px
    final size = widget.isPrimary ? 48.0 : 48.0;
    final iconSize = widget.isPrimary ? 20.0 : 18.0;
    final bgColor = widget.isPrimary
        ? AppColors.primary.withValues(alpha: _isPressed ? 0.8 : 0.9)
        : (_isPressed
            ? AppColors.surface.withValues(alpha: 0.5)
            : AppColors.surface.withValues(alpha: 0.3));

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: Semantics(
        label: widget.tooltip,
        button: true,
        enabled: widget.onTap != null,
        child: Tooltip(
          message: widget.tooltip,
          preferBelow: true,
          waitDuration: AppAnimations.slower,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            onTap: widget.onTap,
            child: AnimatedContainer(
              duration: AppAnimations.paletteSelector,
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(widget.isPrimary ? 14 : 10),
                border: Border.all(
                  color: _isPressed
                      ? AppColors.primary.withValues(alpha: 0.5)
                      : Colors.white.withValues(alpha: 0.1),
                  width: _isPressed ? 1.5 : 1,
                ),
                boxShadow: [
                  if (widget.isPrimary)
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      spreadRadius: 0,
                    ),
                ],
              ),
              child: Center(
                child: Icon(
                  widget.icon,
                  size: iconSize,
                  color: widget.isPrimary
                      ? Colors.white
                      : (_isPressed
                          ? AppColors.primary
                          : AppColors.textSecondary),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Auto-explore toggle button with animated state.
class _AutoExploreToggle extends StatelessWidget {
  final Duration delay;
  final VoidCallback? onLongPress;

  const _AutoExploreToggle({
    required this.delay,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final service = context.watch<AutoExploreService>();
    final isActive = service.isExploring;
    final l10n = AppLocalizations.of(context)!;

    return _ElegantIconButton(
      icon: isActive ? Icons.pause_rounded : Icons.play_arrow_rounded,
      tooltip: isActive ? l10n.autoExplorePause : l10n.autoExploreStart,
      onTap: () {
        HapticService.medium();
        if (isActive) {
          service.stop();
        } else {
          service.start();
        }
      },
      isPrimary: isActive,
      delay: delay,
    );
  }
}

extension on AppLocalizations {
  String get autoExploreStart => 'Start auto-explore';
  String get autoExplorePause => 'Pause auto-explore';
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_fractals/core/services/accessibility_service.dart';
import 'package:flutter_fractals/core/services/haptic_service.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/core/widgets/animated_widgets.dart';
import 'package:flutter_fractals/features/auto_explore/auto_explore.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';

/// Compact control button sizes (WCAG 2.2 minimum 48x48px touch target).
class _ControlSizes {
  static const double primaryButton = 48;
  static const double secondaryButton = 48;
  static const double borderRadius = 10;
  static const double iconSize = 18;
  static const double primaryIconSize = 20;
  static const double spacing = 6;
  static const double groupSpacing = 4;
  static const double shadowBlur = 6;
  static const double shadowBlurPressed = 8;
  static const Offset shadowOffset = Offset(0, 2);
}

class FractalViewControls extends StatelessWidget {
  final AnimationController fabController;
  final AutoExploreService? autoExploreService;
  final bool isExporting;
  final String backTooltip;
  final VoidCallback onGoBack;
  final VoidCallback onToggleFullscreen;
  final VoidCallback onOpenAutoExploreSettings;
  final VoidCallback onOpenControls;
  final VoidCallback onOpenExport;
  final VoidCallback onRandomFractal;

  const FractalViewControls({
    super.key,
    required this.fabController,
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
                // Navigation group
                FloatingActionButtonWidget(
                  icon: Icons.arrow_back_rounded,
                  tooltip: backTooltip,
                  onPressed: isExporting ? null : onGoBack,
                  delay: Duration.zero,
                ),
                const SizedBox(height: _ControlSizes.groupSpacing),
                FloatingActionButtonWidget(
                  icon: Icons.fullscreen_rounded,
                  tooltip: l10n.tooltipFullscreen,
                  onPressed: isExporting ? null : onToggleFullscreen,
                  delay: AppAnimations.controlReveal,
                ),
                const SizedBox(height: _ControlSizes.spacing),
                // Auto-explore button
                if (autoExploreService != null)
                  ChangeNotifierProvider<AutoExploreService>.value(
                    value: autoExploreService!,
                    child: AutoExploreButton(
                      delay: AppAnimations.presetItemDelay,
                      onLongPress:
                          isExporting ? null : onOpenAutoExploreSettings,
                    ),
                  ),
                if (autoExploreService != null)
                  const SizedBox(height: _ControlSizes.spacing),
                // Action group
                FloatingActionButtonWidget(
                  key: const ValueKey('viewerRandomFractalButton'),
                  icon: Icons.shuffle_rounded,
                  tooltip: l10n.tooltipRandomFractal,
                  onPressed: isExporting ? null : onRandomFractal,
                  delay: AppAnimations.controlRevealDelay,
                ),
                const SizedBox(height: _ControlSizes.groupSpacing),
                FloatingActionButtonWidget(
                  key: const ValueKey('viewerExportButton'),
                  icon: Icons.share_rounded,
                  tooltip: l10n.tooltipShare,
                  onPressed: isExporting ? null : onOpenExport,
                  delay: AppAnimations.viewerControlReveal3,
                ),
                const SizedBox(height: _ControlSizes.spacing),
                // Primary control button
                FloatingActionButtonWidget(
                  key: const ValueKey('viewerControlsButton'),
                  icon: Icons.tune_rounded,
                  tooltip: l10n.tooltipOpenControls,
                  onPressed: isExporting ? null : onOpenControls,
                  isPrimary: true,
                  delay: AppAnimations.viewerControlReveal4,
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

class _FloatingActionButtonWidgetState
    extends State<FloatingActionButtonWidget> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    // Check for reduced motion preference
    final reduceMotion = MediaQuery.of(context).disableAnimations ||
        (context.read<AccessibilityService?>()?.reducedMotionEnabled ?? false);

    final buttonSize = widget.isPrimary
        ? _ControlSizes.primaryButton
        : _ControlSizes.secondaryButton;
    final iconSize = widget.isPrimary
        ? _ControlSizes.primaryIconSize
        : _ControlSizes.iconSize;

    return FadeIn(
      delay: reduceMotion ? Duration.zero : widget.delay,
      child: Semantics(
        label: widget.tooltip,
        button: true,
        enabled: widget.onPressed != null,
        child: Tooltip(
          message: widget.tooltip,
          child: GestureDetector(
            onTapDown: (widget.onPressed != null)
                ? (_) {
                    setState(() => _isPressed = true);
                    HapticService.medium();
                  }
                : null,
            onTapUp: (widget.onPressed != null)
                ? (_) {
                    setState(() => _isPressed = false);
                  }
                : null,
            onTapCancel: (widget.onPressed != null)
                ? () {
                    setState(() => _isPressed = false);
                  }
                : null,
            onTap: widget.onPressed,
            child: AnimatedContainer(
              duration: reduceMotion ? Duration.zero : AppAnimations.fast,
              width: buttonSize,
              height: buttonSize,
              decoration: BoxDecoration(
                gradient: widget.isPrimary ? AppColors.primaryGradient : null,
                color: widget.isPrimary ? null : AppColors.surface,
                borderRadius: BorderRadius.circular(_ControlSizes.borderRadius),
                border: widget.isPrimary
                    ? null
                    : Border.all(
                        color: _isPressed
                            ? AppColors.primary.withValues(alpha: 0.4)
                            : AppColors.border.withValues(alpha: 0.3),
                        width: _isPressed ? 1.5 : 1,
                      ),
                boxShadow: [
                  BoxShadow(
                    color: widget.isPrimary
                        ? AppColors.primary
                            .withValues(alpha: _isPressed ? 0.4 : 0.25)
                        : Colors.black.withValues(alpha: 0.15),
                    blurRadius: _isPressed
                        ? _ControlSizes.shadowBlurPressed
                        : _ControlSizes.shadowBlur,
                    offset: _ControlSizes.shadowOffset,
                  ),
                ],
              ),
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
    );
  }
}

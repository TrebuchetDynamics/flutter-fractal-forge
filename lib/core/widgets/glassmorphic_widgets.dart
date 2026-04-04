import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';

/// A glassmorphic container that creates a frosted glass effect.
///
/// Uses BackdropFilter for the blur effect and a semi-transparent
/// gradient overlay for the glass appearance.
class GlassmorphicContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blurSigma;
  final Color? tintColor;
  final double opacity;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final Border? border;

  const GlassmorphicContainer({
    super.key,
    required this.child,
    this.borderRadius = 16.0,
    this.blurSigma = 10.0,
    this.tintColor,
    this.opacity = 0.15,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final color = tintColor ?? AppColors.surface;

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: blurSigma,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withValues(alpha: opacity * 0.6),
                  color.withValues(alpha: opacity),
                ],
              ),
              borderRadius: BorderRadius.circular(borderRadius),
              border: border ??
                  Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                    width: 1,
                  ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// An animated glassmorphic button with press effects.
class GlassmorphicButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double borderRadius;
  final double blurSigma;
  final Color? tintColor;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;

  const GlassmorphicButton({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.borderRadius = 12.0,
    this.blurSigma = 8.0,
    this.tintColor,
    this.padding,
    this.width,
    this.height,
  });

  @override
  State<GlassmorphicButton> createState() => _GlassmorphicButtonState();
}

class _GlassmorphicButtonState extends State<GlassmorphicButton> {
  bool _isPressed = false;
  bool _isHovered = false;

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    HapticFeedback.lightImpact();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final scale = _isPressed ? 0.95 : 1.0;
    final opacity = _isPressed ? 0.3 : (_isHovered ? 0.25 : 0.15);

    return GestureDetector(
      onTapDown: widget.onTap != null ? _handleTapDown : null,
      onTapUp: widget.onTap != null ? _handleTapUp : null,
      onTapCancel: widget.onTap != null ? _handleTapCancel : null,
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: widget.onTap != null
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        child: AnimatedScale(
          scale: scale,
          duration: AppAnimations.paletteSelector,
          curve: Curves.easeOutCubic,
          child: GlassmorphicContainer(
            width: widget.width,
            height: widget.height,
            borderRadius: widget.borderRadius,
            blurSigma: widget.blurSigma,
            tintColor: widget.tintColor,
            opacity: opacity,
            padding: widget.padding,
            border: Border.all(
              color: _isPressed
                  ? AppColors.primary.withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.1),
              width: _isPressed ? 2 : 1,
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// A floating glassmorphic action button with premium styling.
class GlassmorphicFab extends StatelessWidget {
  final IconData icon;
  final String? tooltip;
  final VoidCallback? onTap;
  final bool isPrimary;
  final double size;

  const GlassmorphicFab({
    super.key,
    required this.icon,
    this.tooltip,
    this.onTap,
    this.isPrimary = false,
    this.size = 48.0,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = isPrimary ? Colors.white : AppColors.textPrimary;
    final gradientColors =
        isPrimary ? [AppColors.primary, AppColors.secondary] : null;

    Widget button = GlassmorphicButton(
      onTap: onTap,
      borderRadius: size / 2,
      blurSigma: isPrimary ? 12.0 : 8.0,
      tintColor: isPrimary ? AppColors.primary : null,
      padding: EdgeInsets.all(size * 0.25),
      width: size,
      height: size,
      child: Container(
        decoration: isPrimary
            ? BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors!,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(size / 2),
              )
            : null,
        child: Icon(
          icon,
          color: iconColor,
          size: size * 0.4,
        ),
      ),
    );

    if (tooltip != null) {
      button = Tooltip(
        message: tooltip!,
        preferBelow: true,
        child: button,
      );
    }

    return button;
  }
}

/// A glassmorphic card for displaying information.
class GlassmorphicCard extends StatelessWidget {
  final Widget child;
  final String? title;
  final Widget? trailing;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const GlassmorphicCard({
    super.key,
    required this.child,
    this.title,
    this.trailing,
    this.borderRadius = 16.0,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      borderRadius: borderRadius,
      blurSigma: 15.0,
      opacity: 0.12,
      padding: padding ?? const EdgeInsets.all(16.0),
      margin: margin,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null || trailing != null)
            Row(
              children: [
                if (title != null)
                  Expanded(
                    child: Text(
                      title!,
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                if (trailing != null) trailing!,
              ],
            ),
          if (title != null || trailing != null) const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

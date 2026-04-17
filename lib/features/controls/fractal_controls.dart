import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/core/widgets/animated_widgets.dart';
import 'package:flutter_fractals/core/widgets/animation_effects.dart';
import 'package:flutter_fractals/features/renderer/providers/fractal_provider.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_fractals/shared/widgets/app_bottom_sheet.dart';

class FractalControlsSheet extends StatelessWidget {
  const FractalControlsSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<FractalController>();
    final l10n = AppLocalizations.of(context)!;

    return AppBottomSheet(
      maxHeightFactor: 0.38,
      children: [
        AppBottomSheetHeader(
          icon: Icons.tune_rounded,
          title: l10n.controlsTitle,
          subtitle: controller.module.displayName(l10n),
          onClose: () => Navigator.of(context).pop(),
        ),
        const Divider(height: 1, color: AppColors.divider),
        // Scrollable content
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.sm,
              AppSpacing.xs,
              AppSpacing.sm,
              AppSpacing.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(title: l10n.controlsTitle),
                ...controller.module.parameters.asMap().entries.map((entry) {
                  return StaggeredItem(
                    index: entry.key,
                    itemDelay: const Duration(milliseconds: 30),
                    child: _ParamControl(
                      param: entry.value,
                      value: controller.params[entry.value.id] ??
                          entry.value.defaultValue,
                      onChanged: (value) =>
                          controller.updateParam(entry.value.id, value),
                    ),
                  );
                }),
                const SizedBox(height: AppSpacing.lg),
                SectionHeader(title: 'Kaleidoscope'),
                const SizedBox(height: AppSpacing.sm),
                _KaleidoscopeControls(),
                const SizedBox(height: AppSpacing.xl),
                SectionHeader(title: l10n.sectionActions),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.restart_alt_rounded,
                        label: l10n.resetView,
                        onPressed: controller.resetView,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.settings_backup_restore_rounded,
                        label: l10n.resetParams,
                        onPressed: controller.resetParams,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: _AnimatedRandomizeButton(
                    label: l10n.randomize,
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      controller.randomizeParams();
                      // Trigger a small celebration for discovering new fractals
                      controller.recordInterestingSpot();
                    },
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom + AppSpacing.lg),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: PressableScale(
        onTap: onPressed,
        builder: (isPressed) => AnimatedContainer(
          duration: AppAnimations.fast,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xs,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: isPressed
                ? AppColors.primary.withValues(alpha: 0.3)
                : AppColors.border.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isPressed ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTypography.labelSmall.copyWith(
                  color: isPressed ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompactParamSlider extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final String valueLabel;
  final ValueChanged<double> onChanged;

  const _CompactParamSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.valueLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              valueLabel,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 3,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.surfaceVariant,
            thumbColor: Colors.white,
          ),
          child: Semantics(
            label: label,
            value: valueLabel,
            hint: AppLocalizations.of(context)!.semanticSliderAdjust(min, max),
            slider: true,
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

class _ParamControl extends StatelessWidget {
  final FractalParameter param;
  final Object value;
  final ValueChanged<Object> onChanged;

  const _ParamControl({
    required this.param,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    switch (param.type) {
      case FractalParamType.float:
      case FractalParamType.integer:
        final v = value;
        final doubleValue = v is num ? v.toDouble() : param.min;
        final divisions = ((param.max - param.min) / param.step).round();

        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: _CompactParamSlider(
            label: param.label(l10n),
            value: doubleValue.clamp(param.min, param.max),
            min: param.min,
            max: param.max,
            divisions: divisions > 0 ? divisions : null,
            valueLabel: param.type == FractalParamType.integer
                ? doubleValue.round().toString()
                : doubleValue.toStringAsFixed(2),
            onChanged: (newValue) {
              if (param.type == FractalParamType.integer) {
                onChanged(newValue.round());
              } else {
                onChanged(double.parse(newValue.toStringAsFixed(2)));
              }
            },
          ),
        );

      case FractalParamType.enumeration:
        // Use horizontal scroll for large option sets (e.g. 64 palettes).
        final useScroll = param.options.length > 8;
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                param.label(l10n),
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              if (useScroll)
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: param.options.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(width: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final option = param.options[index];
                      final selected = option.value == value;
                      return _OptionChip(
                        label: option.label(l10n),
                        selected: selected,
                        onSelected: () => onChanged(option.value),
                      );
                    },
                  ),
                )
              else
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: param.options.map((option) {
                    final selected = option.value == value;
                    return _OptionChip(
                      label: option.label(l10n),
                      selected: selected,
                      onSelected: () => onChanged(option.value),
                    );
                  }).toList(),
                ),
            ],
          ),
        );

      case FractalParamType.boolean:
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: _PremiumSwitch(
            label: param.label(l10n),
            value: value == true,
            onChanged: (newValue) => onChanged(newValue),
          ),
        );
    }
  }
}

class _KaleidoscopeControls extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = context.watch<FractalController>();

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                icon: Icons.auto_awesome,
                label: 'Activar',
                onPressed: () => controller.setKaleidoscopeEnabled(!(controller.kaleidoscopeEnabled ?? false)),
              ),
            ),
          ],
        ),
        if (controller.kaleidoscopeEnabled ?? false) ...[
          const SizedBox(height: AppSpacing.md),
          _SliderRow(
            label: 'Sectores',
            value: (controller.kaleidoscopeSectors ?? 8).toDouble(),
            min: 4,
            max: 16,
            divisions: 12,
            onChanged: (v) => controller.setKaleidoscopeSectors(v.round()),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _MirrorModeSelector(
                  currentMode: controller.kaleidoscopeMirrorMode ?? 0,
                  onChanged: controller.setKaleidoscopeMirrorMode,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _SliderRow(
                  label: 'Rotar',
                  value: controller.kaleidoscopeRotation ?? 0.0,
                  min: 0,
                  max: 6.28,
                  divisions: 62,
                  onChanged: controller.setKaleidoscopeRotation,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _SliderRow extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
        ),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class _MirrorModeSelector extends StatelessWidget {
  final int currentMode;
  final ValueChanged<int> onChanged;

  const _MirrorModeSelector({
    required this.currentMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final modes = ['Alternado', 'Doble', 'Triple', 'Sin'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Espejo',
          style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 4,
          children: List.generate(4, (index) {
            final selected = currentMode == index;
            return GestureDetector(
              onTap: () => onChanged(index),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: selected ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Text(
                  modes[index],
                  style: TextStyle(
                    fontSize: 10,
                    color: selected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _OptionChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  const _OptionChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: selected ? '$label, selected' : label,
      child: PressableScale(
        onTap: onSelected,
        builder: (isPressed) => AnimatedContainer(
          duration: AppAnimations.normal,
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.2)
                : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
            border: Border.all(
              color: selected
                  ? AppColors.primary.withValues(alpha: 0.6)
                  : AppColors.border.withValues(alpha: 0.4),
            ),
          ),
          child: Text(
            label,
            style: AppTypography.labelMedium.copyWith(
              color: selected ? AppColors.primary : AppColors.textSecondary,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

class _PremiumSwitch extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _PremiumSwitch({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Semantics(
      toggled: value,
      label: value
          ? l10n.semanticToggleOn(label)
          : l10n.semanticToggleOff(label),
      child: GestureDetector(
      onTap: () => onChanged(!value),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: AppAnimations.normal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: value
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.surfaceVariant.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          border: Border.all(
            color: value
                ? AppColors.primary.withValues(alpha: 0.3)
                : AppColors.border.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
      ),
    );
  }
}

/// Animated randomize button with sparkle effects.
class _AnimatedRandomizeButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;

  const _AnimatedRandomizeButton({
    required this.label,
    required this.onPressed,
  });

  @override
  State<_AnimatedRandomizeButton> createState() => _AnimatedRandomizeButtonState();
}

class _AnimatedRandomizeButtonState extends State<_AnimatedRandomizeButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _shakeController;
  late AnimationController _glowController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shakeAnimation;
  late Animation<double> _glowAnimation;
  bool _isPressed = false;
  bool _showSparkle = false;

  @override
  void initState() {
    super.initState();
    
    _scaleController = AnimationController(
      duration: AppAnimations.fast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: AppAnimations.snappyCurve),
    );

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -0.03), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -0.03, end: 0.03), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 0.03, end: -0.02), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -0.02, end: 0.01), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 0.01, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.easeOut,
    ));

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _glowAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 2),
    ]).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _shakeController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _handleTap() {
    widget.onPressed();
    
    // Trigger animations
    _shakeController.forward(from: 0);
    _glowController.forward(from: 0);
    
    setState(() => _showSparkle = true);
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() => _showSparkle = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Semantics(
      button: true,
      label: l10n.semanticRandomizeButton,
      child: SparkleEffect(
      isActive: _showSparkle,
      sparkleCount: 8,
      child: GestureDetector(
        onTapDown: (_) {
          setState(() => _isPressed = true);
          _scaleController.forward();
        },
        onTapUp: (_) {
          setState(() => _isPressed = false);
          _scaleController.reverse();
        },
        onTapCancel: () {
          setState(() => _isPressed = false);
          _scaleController.reverse();
        },
        onTap: _handleTap,
        child: AnimatedBuilder(
          animation: Listenable.merge([_scaleAnimation, _shakeAnimation, _glowAnimation]),
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Transform.rotate(
                angle: _shakeAnimation.value,
                child: Stack(
                children: [
                  // Glow effect
                  if (_glowAnimation.value > 0)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: _glowAnimation.value * 0.5),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                            BoxShadow(
                              color: AppColors.secondary.withValues(alpha: _glowAnimation.value * 0.3),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                      ),
                    ),
                  // Button
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xxl,
                      vertical: AppSpacing.md + 2,
                    ),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: _isPressed ? 0.5 : 0.3),
                          blurRadius: _isPressed ? 16 : 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedRotation(
                          turns: _shakeController.isAnimating ? 0.5 : 0,
                          duration: const Duration(milliseconds: 300),
                          child: const Icon(
                            Icons.shuffle_rounded,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          widget.label,
                          style: AppTypography.labelLarge.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              ),
            );
          },
        ),
      ),
    ),
    );
  }
}

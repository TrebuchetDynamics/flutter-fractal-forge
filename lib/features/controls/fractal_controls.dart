import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/core/widgets/animated_widgets.dart';
import 'package:flutter_fractals/features/renderer/providers/fractal_provider.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';

class FractalControlsSheet extends StatelessWidget {
  const FractalControlsSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<FractalController>();
    final l10n = AppLocalizations.of(context)!;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: AppSpacing.md),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.lg,
              AppSpacing.xl,
              AppSpacing.sm,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.tune_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.controlsTitle,
                        style: AppTypography.headlineMedium,
                      ),
                      Text(
                        controller.module.displayName(l10n),
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.close_rounded,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),
          // Scrollable content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
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
                  const SizedBox(height: AppSpacing.xl),
                  SectionHeader(title: 'Actions'),
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
                    child: GradientButton(
                      onPressed: controller.randomizeParams,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.shuffle_rounded, size: 20),
                          const SizedBox(width: AppSpacing.sm),
                          Text(l10n.randomize),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).padding.bottom + AppSpacing.lg),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton>
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
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
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      onTap: widget.onPressed,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: AppAnimations.fast,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: _isPressed
                ? AppColors.surfaceElevated
                : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
            border: Border.all(
              color: _isPressed
                  ? AppColors.primary.withValues(alpha: 0.3)
                  : AppColors.border.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.icon,
                size: 18,
                color: _isPressed ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                widget.label,
                style: AppTypography.labelMedium.copyWith(
                  color: _isPressed ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
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
          padding: const EdgeInsets.only(bottom: AppSpacing.lg),
          child: PremiumSlider(
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

class _OptionChip extends StatefulWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  const _OptionChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  State<_OptionChip> createState() => _OptionChipState();
}

class _OptionChipState extends State<_OptionChip>
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
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
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onSelected,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: AppAnimations.normal,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: widget.selected
                ? AppColors.primary.withValues(alpha: 0.2)
                : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
            border: Border.all(
              color: widget.selected
                  ? AppColors.primary.withValues(alpha: 0.6)
                  : AppColors.border.withValues(alpha: 0.4),
            ),
          ),
          child: Text(
            widget.label,
            style: AppTypography.labelMedium.copyWith(
              color: widget.selected ? AppColors.primary : AppColors.textSecondary,
              fontWeight: widget.selected ? FontWeight.w600 : FontWeight.w400,
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
    return GestureDetector(
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
    );
  }
}

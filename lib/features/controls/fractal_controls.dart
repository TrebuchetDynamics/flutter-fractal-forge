import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/core/widgets/animated_widgets.dart';
import 'package:flutter_fractals/features/controls/param_control_plan.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_fractals/shared/widgets/app_bottom_sheet.dart';

class FractalControlsSheet extends StatelessWidget {
  const FractalControlsSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<FractalController>();
    final l10n = AppLocalizations.of(context)!;

    return AppBottomSheet(
      maxHeightFactor: 0.62,
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
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ControlCard(
                  title: l10n.sectionParameters,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...controller.module.parameters
                          .asMap()
                          .entries
                          .map((entry) {
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
                    ],
                  ),
                ),
                _ControlCard(
                  title: l10n.dimensionKaleidoscope,
                  child: _KaleidoscopeControls(),
                ),
                _ControlCard(
                  title: l10n.sectionGlow,
                  child: _GlowControls(),
                ),
                _ControlCard(
                  title: l10n.sectionActions,
                  child: Column(
                    children: [
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          _ActionButton(
                            icon: Icons.restart_alt_rounded,
                            label: l10n.resetView,
                            onPressed: controller.resetView,
                          ),
                          _ActionButton(
                            icon: Icons.settings_backup_restore_rounded,
                            label: l10n.resetParams,
                            onPressed: controller.resetParams,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          icon: const Icon(Icons.shuffle_rounded),
                          label: Text(l10n.randomize,
                              semanticsLabel: l10n.semanticRandomizeButton),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(0, 48),
                            padding: const EdgeInsets.all(AppSpacing.sm),
                          ),
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            controller.randomizeParams();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Subtle grouping card with an uppercase [SectionHeader] for the controls
/// sheet, giving the parameter / kaleidoscope / action groups clear hierarchy.
class _ControlCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _ControlCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: title),
          child,
        ],
      ),
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
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label, textAlign: TextAlign.center),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.all(AppSpacing.sm),
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
        final plan = NumericParamControlPlan.fromParam(
          param: param,
          value: value,
        );

        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: _CompactParamSlider(
            label: param.label(l10n),
            value: plan.value,
            min: plan.min,
            max: plan.max,
            divisions: plan.divisions,
            valueLabel: plan.valueLabel,
            onChanged: (newValue) =>
                onChanged(plan.valueForSliderPosition(newValue)),
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
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: param.options
                        .map((option) => Padding(
                              padding:
                                  const EdgeInsets.only(right: AppSpacing.sm),
                              child: _OptionChip(
                                label: option.label(l10n),
                                selected: option.value == value,
                                onSelected: () => onChanged(option.value),
                              ),
                            ))
                        .toList(),
                  ),
                )
              else
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: param.options
                      .map((option) => _OptionChip(
                            label: option.label(l10n),
                            selected: option.value == value,
                            onSelected: () => onChanged(option.value),
                          ))
                      .toList(),
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
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        // A real switch so the enabled state is visible at a glance, instead of
        // a plain button that gave no on/off feedback.
        _PremiumSwitch(
          label: l10n.kaleidoscopeEnable,
          value: controller.kaleidoscopeEnabled,
          onChanged: controller.setKaleidoscopeEnabled,
        ),
        if (controller.kaleidoscopeEnabled) ...[
          const SizedBox(height: AppSpacing.md),
          _SliderRow(
            // Even-only stops (4,6,…,16): reflective sectors must be even to
            // tile without seams.
            label: l10n.kaleidoscopeSectors,
            value: controller.kaleidoscopeSectors.toDouble(),
            min: 4,
            max: 16,
            divisions: 6,
            onChanged: (v) => controller.setKaleidoscopeSectors(v.round()),
          ),
          const SizedBox(height: AppSpacing.sm),
          _MirrorModeSelector(
            currentMode: controller.kaleidoscopeMirrorMode,
            onChanged: controller.setKaleidoscopeMirrorMode,
          ),
          const SizedBox(height: AppSpacing.sm),
          _SliderRow(
            label: l10n.kaleidoscopeRotation,
            value: controller.kaleidoscopeRotation,
            min: 0,
            max: 6.28,
            divisions: 62,
            onChanged: controller.setKaleidoscopeRotation,
          ),
        ],
      ],
    );
  }
}

class _GlowControls extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = context.watch<FractalController>();
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        _PremiumSwitch(
          label: l10n.glowEnable,
          value: controller.glowEnabled,
          onChanged: controller.setGlowEnabled,
        ),
        if (controller.glowEnabled) ...[
          const SizedBox(height: AppSpacing.md),
          // Softness maps to the blur sigma; bounded to [0.1, 5.0] by the
          // controller.
          _SliderRow(
            label: l10n.glowSoftness,
            value: controller.glowSigma,
            min: 0.1,
            max: 5.0,
            divisions: 49,
            onChanged: controller.setGlowSigma,
          ),
          const SizedBox(height: AppSpacing.sm),
          // Strength is the glow layer opacity in [0, 1].
          _SliderRow(
            label: l10n.glowStrength,
            value: controller.glowIntensity,
            min: 0.0,
            max: 1.0,
            divisions: 20,
            onChanged: controller.setGlowIntensity,
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

  /// Formats [value] for screen readers using the same precision implied by
  /// the slider's step size (whole numbers for integer-like sliders such as
  /// sector counts, two decimals otherwise).
  String get _valueLabel {
    final step = divisions > 0 ? (max - min) / divisions : 0.0;
    return step >= 1 ? value.round().toString() : value.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style:
              AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
        ),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
          ),
          child: Semantics(
            label: label,
            value: _valueLabel,
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

class _MirrorModeSelector extends StatelessWidget {
  final int currentMode;
  final ValueChanged<int> onChanged;

  const _MirrorModeSelector({
    required this.currentMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final modes = [
      l10n.kaleidoscopeMirrorAlternate,
      l10n.kaleidoscopeMirrorDouble,
      l10n.kaleidoscopeMirrorTriple,
      l10n.kaleidoscopeMirrorNone,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.kaleidoscopeMirror,
          style:
              AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 4,
          children: List.generate(4, (index) {
            final selected = currentMode == index;
            return _OptionChip(
              label: modes[index],
              selected: selected,
              onSelected: () => onChanged(index),
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
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      materialTapTargetSize: MaterialTapTargetSize.padded,
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
    return Material(
      type: MaterialType.transparency,
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(label),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}

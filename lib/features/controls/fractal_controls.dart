import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/core/widgets/animated_widgets.dart';
import 'package:flutter_fractals/features/controls/fractal_control_value_resolver.dart';
import 'package:flutter_fractals/features/renderer/providers/fractal_provider.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_fractals/shared/widgets/app_bottom_sheet.dart';

class FractalControlsSheet extends StatelessWidget {
  const FractalControlsSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<FractalController>();
    final l10n = AppLocalizations.of(context)!;
    final actions = _buildActions(controller, l10n);

    return AppBottomSheet(
      maxHeightFactor: 0.48,
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
              AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ParameterControlList(controller: controller),
                const SizedBox(height: AppSpacing.sm),
                _ActionButtonRow(actions: actions),
                SizedBox(
                  height: MediaQuery.of(context).padding.bottom + AppSpacing.sm,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<_ControlAction> _buildActions(
    FractalController controller,
    AppLocalizations l10n,
  ) {
    return [
      _ControlAction(
        icon: Icons.restart_alt_rounded,
        label: l10n.resetView,
        onPressed: controller.resetView,
      ),
      _ControlAction(
        icon: Icons.settings_backup_restore_rounded,
        label: l10n.resetParams,
        onPressed: controller.resetParams,
      ),
      _ControlAction(
        icon: Icons.shuffle_rounded,
        label: l10n.randomize,
        onPressed: () {
          HapticFeedback.mediumImpact();
          controller.randomizeParams();
          controller.recordInterestingSpot();
        },
      ),
    ];
  }
}

class _ParameterControlList extends StatelessWidget {
  final FractalController controller;

  const _ParameterControlList({required this.controller});

  @override
  Widget build(BuildContext context) {
    final parameters = controller.module.parameters;

    return Column(
      children: [
        for (final entry in parameters.asMap().entries)
          StaggeredItem(
            index: entry.key,
            itemDelay: const Duration(milliseconds: 30),
            child: _ParameterControl(
              parameter: entry.value,
              rawValue:
                  controller.params[entry.value.id] ?? entry.value.defaultValue,
              onChanged: (value) =>
                  controller.updateParam(entry.value.id, value),
            ),
          ),
      ],
    );
  }
}

class _ActionButtonRow extends StatelessWidget {
  final List<_ControlAction> actions;

  const _ActionButtonRow({required this.actions});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int index = 0; index < actions.length; index++) ...[
          if (index > 0) const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _ActionButton(
              action: actions[index],
            ),
          ),
        ],
      ],
    );
  }
}

class _ControlAction {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _ControlAction({
    required this.icon,
    required this.label,
    required this.onPressed,
  });
}

class _ActionButton extends StatelessWidget {
  final _ControlAction action;

  const _ActionButton({
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: action.label,
      child: PressableScale(
        onTap: action.onPressed,
        builder: (isPressed) => AnimatedContainer(
          duration: AppAnimations.fast,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xs,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: isPressed
                ? AppColors.surfaceElevated
                : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
            border: Border.all(
              color: isPressed
                  ? AppColors.primary.withValues(alpha: 0.3)
                  : AppColors.border.withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                action.icon,
                size: 18,
                color: isPressed ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(height: 4),
              Text(
                action.label,
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

class _ParameterControl extends StatelessWidget {
  final FractalParameter parameter;
  final Object rawValue;
  final ValueChanged<Object> onChanged;

  const _ParameterControl({
    required this.parameter,
    required this.rawValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    switch (parameter.type) {
      case FractalParamType.float:
      case FractalParamType.integer:
        return _buildNumericControl(l10n);

      case FractalParamType.enumeration:
        return _buildEnumerationControl(l10n);

      case FractalParamType.boolean:
        return _buildBooleanControl(l10n);
    }
  }

  Widget _buildNumericControl(AppLocalizations l10n) {
    final resolvedValue = FractalControlValueResolver.resolveNumeric(
      parameter: parameter,
      rawValue: rawValue,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: _CompactParamSlider(
        label: parameter.label(l10n),
        value: resolvedValue.sliderValue,
        min: resolvedValue.min,
        max: resolvedValue.max,
        divisions: resolvedValue.divisions,
        valueLabel: resolvedValue.valueLabel,
        onChanged: (newValue) => onChanged(
          resolvedValue.valueFromSlider(newValue),
        ),
      ),
    );
  }

  Widget _buildEnumerationControl(AppLocalizations l10n) {
    final selectedValue = FractalControlValueResolver.normalizeEnumerationValue(
      parameter: parameter,
      rawValue: rawValue,
    );
    final useScrollableOptions =
        FractalControlValueResolver.useScrollableOptions(parameter);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            parameter.label(l10n),
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (useScrollableOptions)
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: parameter.options.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final option = parameter.options[index];
                  return _OptionChip(
                    label: option.label(l10n),
                    selected: option.value == selectedValue,
                    onSelected: () => onChanged(option.value),
                  );
                },
              ),
            )
          else
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: parameter.options.map((option) {
                return _OptionChip(
                  label: option.label(l10n),
                  selected: option.value == selectedValue,
                  onSelected: () => onChanged(option.value),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildBooleanControl(AppLocalizations l10n) {
    final value = FractalControlValueResolver.normalizeBooleanValue(
      parameter: parameter,
      rawValue: rawValue,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: _BooleanSwitchTile(
        label: parameter.label(l10n),
        value: value,
        onChanged: (newValue) => onChanged(newValue),
      ),
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
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
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

class _BooleanSwitchTile extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _BooleanSwitchTile({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Semantics(
      toggled: value,
      button: true,
      label:
          value ? l10n.semanticToggleOn(label) : l10n.semanticToggleOff(label),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onChanged(!value),
          borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
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
                Expanded(
                  child: Text(
                    label,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                ExcludeSemantics(
                  child: IgnorePointer(
                    child: Switch(
                      value: value,
                      onChanged: (_) {},
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

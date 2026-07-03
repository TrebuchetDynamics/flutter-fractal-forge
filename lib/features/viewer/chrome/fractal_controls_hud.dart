import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/features/controls/param_control_plan.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';

/// Game-like HUD overlay for fractal parameter controls.
///
/// Replaces the modal bottom sheet with a semi-transparent overlay that
/// appears at the bottom of the fractal view. The fractal remains visible
/// and updating behind the controls, giving an immersive "game HUD" feel.
///
/// Features:
/// - Glass-morphism background (BackdropFilter blur)
/// - Compact horizontal sliders for core params
/// - Chip-based color scheme selector
/// - Collapsible kaleidoscope section
/// - Quick action buttons (reset, randomize)
/// - Animated slide-in/out
class FractalControlsHud extends StatelessWidget {
  final VoidCallback? onClose;

  const FractalControlsHud({super.key, this.onClose});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<FractalController>();
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withValues(alpha: 0.92),
            Colors.black.withValues(alpha: 0.45),
          ],
        ),
      ),
      child: Column(
        children: [
          // Drag handle + close button row
          Padding(
            padding: const EdgeInsets.only(
              top: 8,
              right: 8,
              left: 8,
            ),
            child: Row(
              children: [
                // Drag handle hint
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.controlsTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                // Close button
                _HudIconButton(
                  icon: Icons.close_rounded,
                  tooltip: l10n.semanticCloseButton,
                  onPressed: onClose ?? () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          // Scrollable controls content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Core params: iterations, bailout
                  _CompactHudSliderRow(
                    label: l10n.paramIterations,
                    value: _numParam(controller, 'iterations', 120),
                    min: 20,
                    max: controller.module.parameters
                        .firstWhere((p) => p.id == 'iterations')
                        .max,
                    divisions: null,
                    valueLabel: _numParam(controller, 'iterations', 120)
                        .round()
                        .toString(),
                    semanticLabel: l10n.paramIterations,
                    onChanged: (v) =>
                        controller.updateParam('iterations', v.round()),
                  ),
                  const SizedBox(height: 4),
                  _CompactHudSliderRow(
                    label: l10n.paramBailout,
                    value: _numParam(controller, 'bailout', 4.0),
                    min: 2.0,
                    max: 8.0,
                    divisions: 60,
                    valueLabel: _numParam(controller, 'bailout', 4.0)
                        .toStringAsFixed(1),
                    semanticLabel: l10n.paramBailout,
                    onChanged: (v) => controller.updateParam('bailout', v),
                  ),
                  const SizedBox(height: 8),

                  // Color scheme - compact horizontal chip row
                  _CompactColorSchemeRow(
                    currentValue: _intParam(controller, 'colorScheme', 0),
                    onChanged: (v) => controller.updateParam('colorScheme', v),
                  ),
                  const SizedBox(height: 8),

                  // Extra params (per-fractal)
                  ...controller.module.parameters
                      .where((p) =>
                          p.id != 'iterations' &&
                          p.id != 'bailout' &&
                          p.id != 'colorScheme')
                      .map((param) {
                    final value =
                        controller.params[param.id] ?? param.defaultValue;
                    return _buildExtraParamControl(
                      context,
                      controller,
                      param,
                      value,
                      l10n,
                    );
                  }),

                  const SizedBox(height: 4),

                  // Kaleidoscope toggle + controls
                  _KaleidoscopeSection(controller: controller, l10n: l10n),

                  const SizedBox(height: 4),
                  _HudToggleRow(
                    label: 'Fluid mode',
                    value: controller.fluidModeEnabled,
                    onChanged: controller.setFluidModeEnabled,
                  ),

                  const SizedBox(height: 8),

                  // Quick action buttons row
                  _ActionButtonsRow(
                    onResetView: controller.resetView,
                    onResetParams: controller.resetParams,
                    onRandomize: () {
                      HapticFeedback.mediumImpact();
                      controller.randomizeParams();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExtraParamControl(
    BuildContext context,
    FractalController controller,
    FractalParameter param,
    Object value,
    AppLocalizations l10n,
  ) {
    switch (param.type) {
      case FractalParamType.float:
      case FractalParamType.integer:
        final plan = NumericParamControlPlan.fromParam(
          param: param,
          value: value,
        );
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: _CompactHudSliderRow(
            label: param.label(l10n),
            value: plan.value,
            min: plan.min,
            max: plan.max,
            divisions: plan.divisions,
            valueLabel: plan.valueLabel,
            semanticLabel: param.label(l10n),
            onChanged: (v) => controller.updateParam(
                param.id, plan.valueForSliderPosition(v)),
          ),
        );

      case FractalParamType.enumeration:
        // Show as compact chips
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                param.label(l10n),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                height: 32,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: param.options.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 4),
                  itemBuilder: (context, index) {
                    final option = param.options[index];
                    final selected = option.value == value;
                    return _HudChip(
                      label: option.label(l10n),
                      selected: selected,
                      onTap: () =>
                          controller.updateParam(param.id, option.value),
                    );
                  },
                ),
              ),
            ],
          ),
        );

      case FractalParamType.boolean:
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: _HudToggleRow(
            label: param.label(l10n),
            value: value == true,
            onChanged: (v) => controller.updateParam(param.id, v),
          ),
        );
    }
  }

  double _numParam(FractalController c, String id, double fallback) {
    final v = c.params[id];
    if (v is num) return v.toDouble();
    return fallback;
  }

  int _intParam(FractalController c, String id, int fallback) {
    final v = c.params[id];
    if (v is num) return v.toInt();
    return fallback;
  }
}

/// A compact HUD slider row with label on left, value on right.
class _CompactHudSliderRow extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final String valueLabel;
  final String semanticLabel;
  final ValueChanged<double> onChanged;

  const _CompactHudSliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    this.divisions,
    required this.valueLabel,
    required this.semanticLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              valueLabel,
              style: const TextStyle(
                color: Colors.cyanAccent,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        Semantics(
          label: semanticLabel,
          value: valueLabel,
          hint: l10n.semanticSliderAdjust(min, max),
          slider: true,
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
              activeTrackColor: Colors.cyanAccent,
              inactiveTrackColor: Colors.white.withValues(alpha: 0.15),
              thumbColor: Colors.white,
              valueIndicatorColor: Colors.cyanAccent,
              valueIndicatorTextStyle: const TextStyle(
                color: Colors.black,
                fontSize: 10,
              ),
            ),
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
              onChangeEnd: (v) => HapticFeedback.lightImpact(),
            ),
          ),
        ),
      ],
    );
  }
}

/// Compact color scheme selector row with horizontal scrollable chips.
class _CompactColorSchemeRow extends StatelessWidget {
  final int currentValue;
  final ValueChanged<int> onChanged;

  const _CompactColorSchemeRow({
    required this.currentValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<FractalController>();
    final colorSchemeParam =
        controller.module.parameters.firstWhere((p) => p.id == 'colorScheme');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Palette',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 32,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: colorSchemeParam.options.length,
            separatorBuilder: (_, __) => const SizedBox(width: 4),
            itemBuilder: (context, index) {
              final option = colorSchemeParam.options[index];
              final selected = option.value == currentValue;
              return _HudChip(
                label: option.label(AppLocalizations.of(context)!),
                selected: selected,
                onTap: () {
                  final v = option.value;
                  if (v is int) {
                    HapticFeedback.selectionClick();
                    onChanged(v);
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Kaleidoscope toggle and compact controls section.
class _KaleidoscopeSection extends StatelessWidget {
  final FractalController controller;
  final AppLocalizations l10n;

  const _KaleidoscopeSection({
    required this.controller,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Toggle row
        _HudToggleRow(
          label: 'Kaleidoscope',
          value: controller.kaleidoscopeEnabled,
          onChanged: (v) => controller.setKaleidoscopeEnabled(v),
        ),
        if (controller.kaleidoscopeEnabled) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: _CompactHudSliderRow(
                  label: 'Sectors',
                  value: controller.kaleidoscopeSectors.toDouble(),
                  min: 4,
                  max: 16,
                  divisions: 12,
                  valueLabel: controller.kaleidoscopeSectors.toString(),
                  semanticLabel: 'Kaleidoscope sectors',
                  onChanged: (v) =>
                      controller.setKaleidoscopeSectors(v.round()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: _CompactHudSliderRow(
                  label: 'Rotation',
                  value: controller.kaleidoscopeRotation,
                  min: 0,
                  max: 6.28,
                  divisions: 62,
                  valueLabel:
                      controller.kaleidoscopeRotation.toStringAsFixed(2),
                  semanticLabel: 'Kaleidoscope rotation',
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

/// Quick action buttons row (reset view, reset params, randomize).
class _ActionButtonsRow extends StatelessWidget {
  final VoidCallback onResetView;
  final VoidCallback onResetParams;
  final VoidCallback onRandomize;

  const _ActionButtonsRow({
    required this.onResetView,
    required this.onResetParams,
    required this.onRandomize,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _HudActionButton(
          icon: Icons.home_filled,
          label: 'View',
          tooltip: 'Reset view',
          onPressed: onResetView,
        ),
        const SizedBox(width: 8),
        _HudActionButton(
          icon: Icons.settings_backup_restore_rounded,
          label: 'Params',
          tooltip: 'Reset parameters',
          onPressed: onResetParams,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _HudActionButton(
            icon: Icons.shuffle_rounded,
            label: 'Randomize',
            tooltip: 'Randomize parameters',
            onPressed: onRandomize,
            isPrimary: true,
          ),
        ),
      ],
    );
  }
}

/// A small circular icon button for the HUD.
class _HudIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  const _HudIconButton({
    required this.icon,
    required this.tooltip,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: tooltip,
      button: true,
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, size: 20, color: Colors.white70),
          ),
        ),
      ),
    );
  }
}

/// Compact chip for options/palettes in the HUD.
class _HudChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _HudChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: selected ? '$label, selected' : label,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: selected
                ? Colors.cyanAccent.withValues(alpha: 0.25)
                : Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? Colors.cyanAccent.withValues(alpha: 0.6)
                  : Colors.white.withValues(alpha: 0.15),
            ),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: selected
                  ? Colors.cyanAccent
                  : Colors.white.withValues(alpha: 0.7),
              fontSize: 11,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

/// Toggle row for boolean controls in the HUD.
class _HudToggleRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _HudToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: value,
      label: value ? '$label, on' : '$label, off',
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onChanged(!value);
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: value
                ? Colors.cyanAccent.withValues(alpha: 0.1)
                : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: value
                  ? Colors.cyanAccent.withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                width: 36,
                height: 20,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: value ? Colors.cyanAccent : Colors.white24,
                ),
                padding: const EdgeInsets.all(2),
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 200),
                  alignment:
                      value ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Action button for the HUD (compact, horizontal).
class _HudActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool isPrimary;

  const _HudActionButton({
    required this.icon,
    required this.label,
    required this.tooltip,
    this.onPressed,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: tooltip,
      child: Tooltip(
        message: tooltip,
        child: GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            onPressed?.call();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              gradient: isPrimary
                  ? const LinearGradient(
                      colors: [Color(0xFF00BCD4), Color(0xFF26C6DA)])
                  : null,
              color: isPrimary ? null : Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isPrimary
                    ? Colors.transparent
                    : Colors.white.withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 14,
                  color: isPrimary ? Colors.black87 : Colors.white70,
                ),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: isPrimary ? Colors.black87 : Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
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

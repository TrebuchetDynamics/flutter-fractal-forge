import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/features/controls/param_control_plan.dart';
import 'package:flutter_fractals/features/controls/widgets/number_wall_prime_control.dart';
import 'package:flutter_fractals/features/controls/widgets/number_wall_style_controls.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/controllers/input/fractal_effect_input_bounds.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_fractals/shared/widgets/fractal_math_summary.dart';

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
class FractalControlsHud extends StatefulWidget {
  final VoidCallback? onClose;
  final Widget? content;

  const FractalControlsHud({super.key, this.onClose, this.content});

  @override
  State<FractalControlsHud> createState() => _FractalControlsHudState();
}

class _FractalControlsHudState extends State<FractalControlsHud> {
  static const double _dragSnapThreshold = 24;

  bool _isCollapsed = false;
  bool _dragSnapCommitted = false;
  double _dragOffset = 0;

  void _onHandleDragStart(DragStartDetails details) {
    _dragOffset = 0;
    _dragSnapCommitted = false;
  }

  void _onHandleDragUpdate(DragUpdateDetails details) {
    if (_dragSnapCommitted) return;

    _dragOffset += details.delta.dy;
    final shouldCollapse = !_isCollapsed && _dragOffset >= _dragSnapThreshold;
    final shouldExpand = _isCollapsed && _dragOffset <= -_dragSnapThreshold;
    if (shouldCollapse || shouldExpand) {
      _dragSnapCommitted = true;
      setState(() => _isCollapsed = shouldCollapse);
    }
  }

  void _onHandleDragEnd(DragEndDetails details) => _resetHandleDrag();

  void _onHandleDragCancel() => _resetHandleDrag();

  void _resetHandleDrag() {
    _dragOffset = 0;
    _dragSnapCommitted = false;
  }

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
                // Drag handle: short vertical swipes collapse or expand the HUD.
                GestureDetector(
                  key: const ValueKey('controlsHudDragHandle'),
                  behavior: HitTestBehavior.opaque,
                  onVerticalDragStart: _onHandleDragStart,
                  onVerticalDragUpdate: _onHandleDragUpdate,
                  onVerticalDragEnd: _onHandleDragEnd,
                  onVerticalDragCancel: _onHandleDragCancel,
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.controlsTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _HudIconButton(
                  icon: _isCollapsed
                      ? Icons.expand_less_rounded
                      : Icons.expand_more_rounded,
                  tooltip:
                      _isCollapsed ? l10n.tooltipExpand : l10n.tooltipCollapse,
                  onPressed: () => setState(() => _isCollapsed = !_isCollapsed),
                ),
                // Close button
                if (widget.onClose != null || widget.content == null)
                  _HudIconButton(
                    icon: Icons.close_rounded,
                    tooltip: l10n.semanticCloseButton,
                    onPressed:
                        widget.onClose ?? () => Navigator.of(context).pop(),
                  ),
              ],
            ),
          ),
          if (!_isCollapsed && widget.content != null)
            Expanded(child: widget.content!)
          else if (!_isCollapsed)
            // Scrollable controls content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (controller.module.id != 'number_wall' &&
                        (controller.numberWallPending ||
                            controller.numberWallStatus != null))
                      Semantics(
                          liveRegion: true,
                          child: Text(
                              controller.numberWallPending
                                  ? l10n.numberWallComputing
                                  : l10n.numberWallRetainedInvalid,
                              style: const TextStyle(color: Colors.white))),
                    FractalMathSummary(
                      module: controller.module,
                      params: controller.params,
                    ),
                    // Core params are optional: custom modules can expose a
                    // different schema (for example Nova uses relaxation,
                    // not bailout).
                    ...controller.module.parameters
                        .where((p) => p.id == 'iterations' || p.id == 'bailout')
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

                    // Color scheme - compact horizontal chip row
                    if (_hasParam(controller, 'colorScheme')) ...[
                      _CompactColorSchemeRow(
                        currentValue: _intParam(controller, 'colorScheme', 0),
                        onChanged: (v) =>
                            controller.updateParam('colorScheme', v),
                      ),
                      const SizedBox(height: 8),
                    ],

                    // Extra params (per-fractal)
                    ...controller.module.parameters
                        .where((p) =>
                            p.id != 'iterations' &&
                            p.id != 'bailout' &&
                            p.id != 'colorScheme' &&
                            p.id != 'randomSeed')
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
                    if (controller.module.id != 'number_wall')
                      _KaleidoscopeSection(controller: controller, l10n: l10n),

                    const SizedBox(height: 4),
                    if (controller.module.id != 'number_wall')
                      _HudToggleRow(
                        label: l10n.hudFluidMode,
                        value: controller.fluidModeEnabled,
                        onChanged: controller.setFluidModeEnabled,
                      ),
                    if (controller.module.id != 'number_wall' &&
                        controller.fluidModeEnabled) ...[
                      const SizedBox(height: 4),
                      _CompactHudSliderRow(
                        label: l10n.hudFluidIntensity,
                        value: controller.fluidStrength,
                        min: FractalEffectInputBounds.minFluidStrength,
                        max: FractalEffectInputBounds.maxFluidStrength,
                        divisions: 20,
                        valueLabel: controller.fluidStrength.toStringAsFixed(1),
                        semanticLabel: l10n.hudFluidIntensity,
                        onChanged: controller.setFluidStrength,
                      ),
                    ],

                    const SizedBox(height: 8),

                    if (controller.module.id == 'number_wall')
                      const NumberWallRandomizationControls(),
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
    if (controller.module.id == 'number_wall' && isNumberWallColor(param.id)) {
      return NumberWallColorControl(
          param: param,
          value: value,
          onChanged: (v) => controller.updateParam(param.id, v));
    }
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
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: param.options
                      .map((option) => Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: _HudChip(
                              label: option.label(l10n),
                              selected: option.value == value,
                              onTap: () => controller.updateParam(
                                  param.id, option.value),
                            ),
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
        );

      case FractalParamType.decimalInteger:
        return const NumberWallPrimeControl();

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

  bool _hasParam(FractalController c, String id) =>
      c.module.parameters.any((param) => param.id == id);

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
        // The Semantics below already carries this label and value, so reading
        // the visible copy too would announce each slider three times.
        ExcludeSemantics(
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
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
        ),
        // Without the merge the Slider's thumb is its own node, carrying the
        // adjust actions and the percentage but none of the name — so the
        // control announces "69%" and never says which parameter it is.
        MergeSemantics(
          child: Semantics(
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
              // The compact theme (3px track, radius-12 overlay) sizes the
              // Slider's box to 24, so the draggable strip was half the
              // minimum. A tight height grows the hit area without touching
              // the track, thumb or overlay, which stay centred in it.
              child: SizedBox(
                height: AccessibleSizing.minTouchTarget,
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
    final l10n = AppLocalizations.of(context)!;
    final colorSchemeParam =
        controller.module.parameters.firstWhere((p) => p.id == 'colorScheme');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.hudPalette,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: colorSchemeParam.options
                .map((option) => Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: _HudChip(
                        label: option.label(l10n),
                        selected: option.value == currentValue,
                        onTap: () {
                          final v = option.value;
                          if (v is int) {
                            HapticFeedback.selectionClick();
                            onChanged(v);
                          }
                        },
                      ),
                    ))
                .toList(),
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
          label: l10n.hudKaleidoscope,
          value: controller.kaleidoscopeEnabled,
          onChanged: (v) => controller.setKaleidoscopeEnabled(v),
        ),
        if (controller.kaleidoscopeEnabled) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: _CompactHudSliderRow(
                  label: l10n.kaleidoscopeSectors,
                  value: controller.kaleidoscopeSectors.toDouble(),
                  min: 4,
                  max: 16,
                  // Even-only stops (4,6,…,16), matching the full controls
                  // panel: setKaleidoscopeSectors snaps odd values down, so a
                  // step of 1 would make half the detents land nowhere.
                  divisions: 6,
                  valueLabel: controller.kaleidoscopeSectors.toString(),
                  semanticLabel: l10n.hudSemanticKaleidoscopeSectors,
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
                  label: l10n.hudRotation,
                  value: controller.kaleidoscopeRotation,
                  min: 0,
                  max: 6.28,
                  divisions: 62,
                  valueLabel:
                      controller.kaleidoscopeRotation.toStringAsFixed(2),
                  semanticLabel: l10n.hudSemanticKaleidoscopeRotation,
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
    final l10n = AppLocalizations.of(context)!;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _HudActionButton(
          icon: Icons.home_filled,
          label: l10n.hudResetViewLabel,
          tooltip: l10n.resetView,
          onPressed: onResetView,
        ),
        _HudActionButton(
          icon: Icons.settings_backup_restore_rounded,
          label: l10n.hudResetParamsLabel,
          tooltip: l10n.resetParams,
          onPressed: onResetParams,
        ),
        _HudActionButton(
          icon: Icons.shuffle_rounded,
          label: l10n.randomize,
          tooltip: l10n.hudRandomizeTooltip,
          onPressed: onRandomize,
          isPrimary: true,
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
          borderRadius: BorderRadius.circular(24),
          // The circle stays 36 so the HUD keeps its density, but the tappable
          // area is padded out to the 48 minimum — this is the only way to
          // dismiss the HUD, so it should not be the smallest target in it.
          child: SizedBox.square(
            dimension: AccessibleSizing.minTouchTarget,
            child: Center(
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
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      materialTapTargetSize: MaterialTapTargetSize.padded,
      showCheckmark: false,
      backgroundColor: Colors.white.withValues(alpha: 0.08),
      selectedColor: Colors.cyanAccent.withValues(alpha: 0.25),
      side: BorderSide(
          color: selected
              ? Colors.cyanAccent.withValues(alpha: 0.6)
              : Colors.white.withValues(alpha: 0.15)),
      labelStyle: TextStyle(
        color: selected ? Colors.cyanAccent : Colors.white70,
        fontSize: 11,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
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
    return Material(
      type: MaterialType.transparency,
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        title: Text(label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            )),
        value: value,
        activeThumbColor: Colors.cyanAccent,
        onChanged: (next) {
          HapticFeedback.selectionClick();
          onChanged(next);
        },
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
    final style = FilledButton.styleFrom(
      minimumSize: const Size(48, 48),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      foregroundColor: isPrimary ? Colors.black87 : Colors.white70,
      backgroundColor:
          isPrimary ? Colors.cyanAccent : Colors.white.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
    );
    return Tooltip(
      message: tooltip,
      excludeFromSemantics: true,
      child: FilledButton.icon(
        style: style,
        icon: Icon(icon, size: 14),
        label: Text(label, semanticsLabel: tooltip),
        onPressed: onPressed == null
            ? null
            : () {
                HapticFeedback.mediumImpact();
                onPressed!();
              },
      ),
    );
  }
}

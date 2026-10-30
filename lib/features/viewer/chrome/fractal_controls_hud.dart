import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/core/services/platform/accessibility_service.dart';
import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/features/controls/param_control_plan.dart';
import 'package:flutter_fractals/features/controls/widgets/number_wall_prime_control.dart';
import 'package:flutter_fractals/features/controls/widgets/number_wall_style_controls.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/controllers/input/fractal_effect_input_bounds.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_fractals/shared/widgets/fractal_math_summary.dart';
import 'package:flutter_fractals/shared/widgets/app_tool_button.dart';

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
  final Widget? leading;

  const FractalControlsHud(
      {super.key, this.onClose, this.content, this.leading});

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

    final media = MediaQuery.of(context);
    final bottomInset = math.max(
      math.max(media.padding.bottom, media.viewPadding.bottom),
      media.systemGestureInsets.bottom,
    );
    final accessibility = context.watch<AccessibilityService?>();
    final reduceMotion =
        media.disableAnimations || accessibility?.reducedMotionEnabled == true;
    final target = AccessibleSizing.touchTargetSize(
        largeTargets: accessibility?.largeTargetsEnabled == true);
    final headerHeight = math.max(
            target,
            media.textScaler.scale(
                    Theme.of(context).textTheme.titleSmall?.fontSize ?? 14) *
                (Theme.of(context).textTheme.titleSmall?.height ?? 1)) +
        16;
    final header = GestureDetector(
      key: const ValueKey('controlsHudDragHandle'),
      behavior: HitTestBehavior.opaque,
      onVerticalDragStart: _onHandleDragStart,
      onVerticalDragUpdate: _onHandleDragUpdate,
      onVerticalDragEnd: _onHandleDragEnd,
      onVerticalDragCancel: _onHandleDragCancel,
      child: Stack(
        children: [
          Positioned(
            top: 4,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textSecondary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
            child: Row(
              children: [
                if (widget.leading != null) widget.leading!,
                Expanded(
                  child: Text(
                    l10n.controlsTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                AppToolButton(
                  icon: _isCollapsed
                      ? Icons.expand_less_rounded
                      : Icons.expand_more_rounded,
                  tooltip:
                      _isCollapsed ? l10n.tooltipExpand : l10n.tooltipCollapse,
                  onPressed: () => setState(() => _isCollapsed = !_isCollapsed),
                ),
                if (widget.onClose != null || widget.content == null)
                  AppToolButton(
                    icon: Icons.close_rounded,
                    tooltip: l10n.semanticCloseButton,
                    onPressed:
                        widget.onClose ?? () => Navigator.of(context).pop(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
    final content = widget.content ??
        Padding(
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
                collapsible: true,
              ),
              // Core params are optional: custom modules can expose a
              // different schema (for example Nova uses relaxation,
              // not bailout).
              ...controller.module.parameters
                  .where((p) => p.id == 'iterations' || p.id == 'bailout')
                  .map((param) {
                final value = controller.params[param.id] ?? param.defaultValue;
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
                  onChanged: (v) => controller.updateParam('colorScheme', v),
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
                final value = controller.params[param.id] ?? param.defaultValue;
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
        );

    // Only the material surface paints and receives input. In a short body,
    // scroll the header too, rather than reserving a header taller than the
    // remaining viewport. The OS navigation area stays outside that viewport.
    return LayoutBuilder(builder: (context, constraints) {
      final scrollHeader =
          constraints.maxHeight - bottomInset < headerHeight + 1 + target + 16;
      final children = <Widget>[
        header,
        if (!_isCollapsed)
          Divider(
              height: 1, color: Theme.of(context).colorScheme.outlineVariant),
        if (!_isCollapsed)
          if (scrollHeader)
            content
          else
            Flexible(
                child: widget.content ?? SingleChildScrollView(child: content)),
      ];
      final column = Column(mainAxisSize: MainAxisSize.min, children: children);
      final surface = Material(
        key: const ValueKey('controlsHudSurface'),
        color: Theme.of(context).colorScheme.surface,
        elevation: 12,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: EdgeInsets.only(
            left: math.max(math.max(media.padding.left, media.viewPadding.left),
                media.systemGestureInsets.left),
            right: math.max(
                math.max(media.padding.right, media.viewPadding.right),
                media.systemGestureInsets.right),
            bottom: bottomInset,
          ),
          child: scrollHeader ? SingleChildScrollView(child: column) : column,
        ),
      );
      return Align(
        alignment: Alignment.bottomCenter,
        // Duration.zero still runs RenderAnimatedSize's layout state machine.
        child: reduceMotion
            ? surface
            : AnimatedSize(
                duration: AppAnimations.fast,
                alignment: Alignment.bottomCenter,
                child: surface,
              ),
      );
    });
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
                  color: AppColors.textSecondary,
                  fontSize: 13,
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
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  valueLabel,
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    color: Colors.cyanAccent,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
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
                activeTickMarkColor: Colors.transparent,
                inactiveTickMarkColor: Colors.transparent,
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
                height: AccessibleSizing.touchTargetSize(
                    largeTargets: context
                            .watch<AccessibilityService?>()
                            ?.largeTargetsEnabled ==
                        true),
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
            color: AppColors.textSecondary,
            fontSize: 13,
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
          icon: Icons.center_focus_strong_rounded,
          label: l10n.hudResetViewLabel,
          tooltip: l10n.hudResetViewLabel,
          onPressed: onResetView,
        ),
        _HudActionButton(
          icon: Icons.settings_backup_restore_rounded,
          label: l10n.hudResetParamsLabel,
          tooltip: l10n.hudResetParamsLabel,
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
      visualDensity:
          context.watch<AccessibilityService?>()?.largeTargetsEnabled == true
              ? const VisualDensity(vertical: 4)
              : VisualDensity.standard,
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      materialTapTargetSize: MaterialTapTargetSize.padded,
      showCheckmark: true,
      checkmarkColor: Colors.cyanAccent,
      backgroundColor: Colors.white.withValues(alpha: 0.08),
      selectedColor: Colors.cyanAccent.withValues(alpha: 0.25),
      side: BorderSide(
          color: selected
              ? Colors.cyanAccent.withValues(alpha: 0.6)
              : Colors.white.withValues(alpha: 0.15)),
      labelStyle: TextStyle(
        color: selected ? Colors.cyanAccent : Colors.white70,
        fontSize: 12,
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
              fontSize: 14,
              fontWeight: FontWeight.w500,
            )),
        value: value,
        activeThumbColor: Colors.cyanAccent,
        activeTrackColor: Colors.cyanAccent.withValues(alpha: 0.28),
        inactiveThumbColor: AppColors.textSecondary,
        inactiveTrackColor: AppColors.surfaceVariant,
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
    final colors = Theme.of(context).colorScheme;
    final style = FilledButton.styleFrom(
      minimumSize: Size.square(AccessibleSizing.touchTargetSize(
          largeTargets:
              context.watch<AccessibilityService?>()?.largeTargetsEnabled ==
                  true)),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      foregroundColor: isPrimary ? colors.onPrimary : colors.onSurfaceVariant,
      backgroundColor: isPrimary ? colors.primary : colors.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      textStyle: const TextStyle(
          fontFamily: AppTypography.bodyFont,
          fontSize: 13,
          fontWeight: FontWeight.w600),
    );
    return Tooltip(
      message: tooltip,
      excludeFromSemantics: true,
      child: FilledButton(
        style: style,
        child: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 4,
          children: [
            Icon(icon, size: 18),
            Text(label, semanticsLabel: tooltip, textAlign: TextAlign.center),
          ],
        ),
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

import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';

/// Presentation of the sampled Fourier result.
enum FourierDisplayMode { split, spectrum }

/// Maximum analysis dimension. Auto may downshift while the camera moves.
enum FourierResolution {
  auto(null),
  pixels128(128),
  pixels256(256);

  const FourierResolution(this.pixels);
  final int? pixels;
}

class FourierSettingsSheet extends StatelessWidget {
  const FourierSettingsSheet({
    super.key,
    required this.displayMode,
    required this.resolution,
    required this.applyHann,
    required this.removeDc,
    required this.fourierMusicEnabled,
    required this.onDisplayModeChanged,
    required this.onResolutionChanged,
    required this.onApplyHannChanged,
    required this.onRemoveDcChanged,
    required this.onFourierMusicChanged,
    required this.onOpenUncertaintyLab,
  });

  final FourierDisplayMode displayMode;
  final FourierResolution resolution;
  final bool applyHann;
  final bool removeDc;
  final bool fourierMusicEnabled;
  final ValueChanged<FourierDisplayMode> onDisplayModeChanged;
  final ValueChanged<FourierResolution> onResolutionChanged;
  final ValueChanged<bool> onApplyHannChanged;
  final ValueChanged<bool> onRemoveDcChanged;
  final ValueChanged<bool> onFourierMusicChanged;
  final VoidCallback onOpenUncertaintyLab;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      minimum: EdgeInsets.only(
        bottom: MediaQuery.systemGestureInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.fourierSettingsTitle,
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.md),
            Text(l10n.fourierDisplay,
                style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: AppSpacing.sm),
            SegmentedButton<FourierDisplayMode>(
              segments: [
                ButtonSegment(
                  value: FourierDisplayMode.split,
                  label: Text(l10n.fourierSplit),
                  icon: const Icon(Icons.vertical_split_rounded),
                ),
                ButtonSegment(
                  value: FourierDisplayMode.spectrum,
                  label: Text(l10n.fourierSpectrum),
                  icon: const Icon(Icons.blur_on_rounded),
                ),
              ],
              selected: {displayMode},
              onSelectionChanged: (values) =>
                  onDisplayModeChanged(values.single),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(l10n.fourierResolution,
                style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: AppSpacing.sm),
            SegmentedButton<FourierResolution>(
              segments: [
                ButtonSegment(
                  value: FourierResolution.auto,
                  label: Text(l10n.fourierResolutionAuto),
                ),
                const ButtonSegment(
                  value: FourierResolution.pixels128,
                  label: Text('128'),
                ),
                const ButtonSegment(
                  value: FourierResolution.pixels256,
                  label: Text('256'),
                ),
              ],
              selected: {resolution},
              onSelectionChanged: (values) =>
                  onResolutionChanged(values.single),
            ),
            const SizedBox(height: AppSpacing.md),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.fourierWindowHann),
              value: applyHann,
              onChanged: onApplyHannChanged,
            ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.fourierRemoveDc),
              value: removeDc,
              onChanged: onRemoveDcChanged,
            ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.fourierMusic),
              subtitle: Text(l10n.fourierMusicDescription),
              value: fourierMusicEnabled,
              onChanged: onFourierMusicChanged,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(l10n.fourierSpatialUnitsNote),
            const SizedBox(height: AppSpacing.sm),
            Text(l10n.fourierBaseFieldNote),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.fourierFiniteDisclaimer,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: onOpenUncertaintyLab,
              icon: const Icon(Icons.science_rounded),
              label: Text(l10n.fourierOpenLab),
            ),
          ],
        ),
      ),
    );
  }
}

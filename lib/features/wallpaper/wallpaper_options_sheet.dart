import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/models/wallpaper/wallpaper_options.dart';
import 'package:flutter_fractals/core/services/platform/haptic_service.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_fractals/shared/widgets/app_bottom_sheet.dart';
import 'package:flutter_fractals/shared/widgets/sheet_section_label.dart';

class WallpaperOptionsSheet extends StatefulWidget {
  final WallpaperOptions initial;

  const WallpaperOptionsSheet({
    super.key,
    required this.initial,
  });

  static Future<WallpaperOptions?> show(
    BuildContext context, {
    WallpaperOptions initial = const WallpaperOptions(),
  }) {
    return showAppBottomSheet<WallpaperOptions>(
      context: context,
      constraints: const BoxConstraints(maxWidth: 720),
      builder: (_) => WallpaperOptionsSheet(initial: initial),
    );
  }

  @override
  State<WallpaperOptionsSheet> createState() => _WallpaperOptionsSheetState();
}

class _WallpaperOptionsSheetState extends State<WallpaperOptionsSheet> {
  late WallpaperOptions _options;

  @override
  void initState() {
    super.initState();
    _options = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final media = MediaQuery.of(context);
    final needsRoom = media.size.height - media.viewInsets.bottom < 500 ||
        media.textScaler.scale(14) > 20;
    return AppDraggableBottomSheet(
      initialChildSize: needsRoom ? 0.92 : 0.78,
      minChildSize: 0.5,
      maxChildSize: 0.92,
      childrenBuilder: (context, scrollController) => [
        Expanded(
          child: ListView(
            controller: scrollController,
            padding: EdgeInsets.zero,
            children: [
              // Scroll the header too: short, enlarged-text viewports must not
              // lose their body to fixed chrome. Apply remains outside the list.
              AppBottomSheetHeader(
                icon: Icons.wallpaper_rounded,
                title: l10n.wallpaperTitle,
                onClose: () => Navigator.of(context).maybePop(),
              ),
              const Divider(height: 1),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      (!kIsWeb && Platform.isIOS)
                          ? l10n.wallpaperIosNote
                          : l10n.wallpaperAndroidNote,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.75),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l10n.wallpaperTarget,
                      style: sheetSectionLabelStyle(theme),
                    ),
                    const SizedBox(height: 12),
                    for (final target in WallpaperTarget.values)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _TargetOption(
                          selected: _options.target == target,
                          label: switch (target) {
                            WallpaperTarget.home => l10n.wallpaperTargetHome,
                            WallpaperTarget.lock => l10n.wallpaperTargetLock,
                            WallpaperTarget.both => l10n.wallpaperTargetBoth,
                          },
                          onTap: () {
                            HapticService.light();
                            setState(() =>
                                _options = _options.copyWith(target: target));
                          },
                        ),
                      ),
                    const SizedBox(height: 20),
                    Text(
                      l10n.wallpaperPresets,
                      style: sheetSectionLabelStyle(theme),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _StyleChip(
                          selected: _options.style == WallpaperStyle.plain,
                          label: l10n.wallpaperPresetPlain,
                          icon: Icons.brush_rounded,
                          onTap: () => setState(() => _options =
                              _options.copyWith(style: WallpaperStyle.plain)),
                        ),
                        _StyleChip(
                          selected:
                              _options.style == WallpaperStyle.homeOptimized,
                          label: l10n.wallpaperPresetHome,
                          icon: Icons.home_rounded,
                          onTap: () => setState(() => _options = _options
                              .copyWith(style: WallpaperStyle.homeOptimized)),
                        ),
                        _StyleChip(
                          selected:
                              _options.style == WallpaperStyle.lockOptimized,
                          label: l10n.wallpaperPresetLock,
                          icon: Icons.lock_rounded,
                          onTap: () => setState(() => _options = _options
                              .copyWith(style: WallpaperStyle.lockOptimized)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile.adaptive(
                      value: _options.saveCopy,
                      onChanged: (v) => setState(
                          () => _options = _options.copyWith(saveCopy: v)),
                      title: Text(l10n.wallpaperSaveCopy),
                      contentPadding: EdgeInsets.zero,
                    ),
                    Text(l10n.wallpaperSaveCopySubtitle,
                        style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                minimumSize: const Size(48, 48),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onPressed: () {
                HapticService.heavy();
                Navigator.of(context).pop(_options);
              },
              icon: const Icon(Icons.wallpaper_rounded),
              label: Text(l10n.wallpaperApply),
            ),
          ),
        ),
      ],
    );
  }
}

class _StyleChip extends StatelessWidget {
  final bool selected;
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _StyleChip({
    required this.selected,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ChoiceChip(
      selected: selected,
      label: Text(label),
      avatar: Icon(icon, size: 18),
      showCheckmark: true,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,
      labelPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      selectedColor: theme.colorScheme.primaryContainer,
      labelStyle: theme.textTheme.labelLarge?.copyWith(
        color: selected
            ? theme.colorScheme.onPrimaryContainer
            : theme.colorScheme.onSurface,
      ),
      onSelected: (_) {
        HapticService.light();
        onTap();
      },
    );
  }
}

/// Radio-style options with full-width labels when a leading control would
/// force a short destination name to break. Text always uses the system scale.
class _TargetOption extends StatelessWidget {
  final bool selected;
  final String label;
  final VoidCallback onTap;

  const _TargetOption(
      {required this.selected, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.labelLarge!;
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 48),
        padding: const EdgeInsets.symmetric(vertical: 12),
        backgroundColor: selected ? theme.colorScheme.primaryContainer : null,
        foregroundColor: selected
            ? theme.colorScheme.onPrimaryContainer
            : theme.colorScheme.onSurface,
        side: BorderSide(
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline),
      ),
      child: Semantics(
        checked: selected,
        selected: selected,
        inMutuallyExclusiveGroup: true,
        child: LayoutBuilder(builder: (context, constraints) {
          final painter = TextPainter(
            text: TextSpan(text: label, style: style),
            textDirection: Directionality.of(context),
            textScaler: MediaQuery.textScalerOf(context),
          )..layout();
          final stacked = painter.width + 64 > constraints.maxWidth;
          painter.dispose();
          final icon = Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 24);
          final text = Text(label);
          return stacked
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [icon, const SizedBox(height: 8), text])
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [icon, const SizedBox(width: 12), text]);
        }),
      ),
    );
  }
}

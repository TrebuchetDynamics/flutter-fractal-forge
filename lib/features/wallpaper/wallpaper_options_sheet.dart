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
  final void Function(WallpaperOptions options) onApply;

  const WallpaperOptionsSheet({
    super.key,
    required this.initial,
    required this.onApply,
  });

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

    return AppDraggableBottomSheet(
      initialChildSize: 0.62,
      minChildSize: 0.5,
      maxChildSize: 0.92,
      childrenBuilder: (context, scrollController) => [
        AppBottomSheetHeader(
          icon: Icons.wallpaper_rounded,
          title: l10n.wallpaperTitle,
          onClose: () => Navigator.of(context).maybePop(),
        ),
        const Divider(height: 1),
        const SizedBox(height: 16),
        Expanded(
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              Text(
                (!kIsWeb && Platform.isIOS)
                    ? l10n.wallpaperIosNote
                    : l10n.wallpaperAndroidNote,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.wallpaperTarget,
                style: sheetSectionLabelStyle(theme),
              ),
              const SizedBox(height: 12),
              SegmentedButton(
                segments: [
                  ButtonSegment(
                    value: WallpaperTarget.home,
                    label: Text(l10n.wallpaperTargetHome),
                    icon: const Icon(Icons.home_rounded),
                  ),
                  ButtonSegment(
                    value: WallpaperTarget.lock,
                    label: Text(l10n.wallpaperTargetLock),
                    icon: const Icon(Icons.lock_rounded),
                  ),
                  ButtonSegment(
                    value: WallpaperTarget.both,
                    label: Text(l10n.wallpaperTargetBoth),
                    icon: const Icon(Icons.layers_rounded),
                  ),
                ],
                selected: {_options.target},
                onSelectionChanged: (s) {
                  HapticService.light();
                  setState(() => _options = _options.copyWith(target: s.first));
                },
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
                    selected: _options.style == WallpaperStyle.homeOptimized,
                    label: l10n.wallpaperPresetHome,
                    icon: Icons.home_rounded,
                    onTap: () => setState(() => _options =
                        _options.copyWith(style: WallpaperStyle.homeOptimized)),
                  ),
                  _StyleChip(
                    selected: _options.style == WallpaperStyle.lockOptimized,
                    label: l10n.wallpaperPresetLock,
                    icon: Icons.lock_rounded,
                    onTap: () => setState(() => _options =
                        _options.copyWith(style: WallpaperStyle.lockOptimized)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SwitchListTile.adaptive(
                value: _options.saveCopy,
                onChanged: (v) =>
                    setState(() => _options = _options.copyWith(saveCopy: v)),
                title: Text(l10n.wallpaperSaveCopy),
                subtitle: Text(l10n.wallpaperSaveCopySubtitle),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 90),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                HapticService.heavy();
                Navigator.of(context).pop();
                widget.onApply(_options);
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: () {
          HapticService.light();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? theme.colorScheme.primaryContainer
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18),
              const SizedBox(width: 8),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}

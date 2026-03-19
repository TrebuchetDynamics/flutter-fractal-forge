import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/models/export_options.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';

enum ExportAction {
  saveOnly,
  saveAndShare,
}

class ExportSheetSubmission {
  final ExportOptions options;
  final ExportAction action;

  const ExportSheetSubmission({
    required this.options,
    required this.action,
  });
}

/// A bottom sheet for configuring export options
class ExportOptionsSheet extends StatefulWidget {
  final ExportOptions initialOptions;
  final String fractalType;

  const ExportOptionsSheet({
    Key? key,
    required this.initialOptions,
    required this.fractalType,
  }) : super(key: key);

  static Future<ExportSheetSubmission?> show(
    BuildContext context, {
    required ExportOptions initialOptions,
    required String fractalType,
  }) {
    return showModalBottomSheet<ExportSheetSubmission>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ExportOptionsSheet(
        initialOptions: initialOptions,
        fractalType: fractalType,
      ),
    );
  }

  @override
  State<ExportOptionsSheet> createState() => _ExportOptionsSheetState();
}

class _ExportOptionsSheetState extends State<ExportOptionsSheet> {
  late ExportOptions _options;
  late TextEditingController _customWidthController;
  late TextEditingController _customHeightController;
  bool _showAdvanced = false;
  bool _showCustomization = false;

  @override
  void initState() {
    super.initState();
    _options = widget.initialOptions;
    _customWidthController = TextEditingController(
      text: _options.customWidth?.toString() ?? '1920',
    );
    _customHeightController = TextEditingController(
      text: _options.customHeight?.toString() ?? '1080',
    );

    // Keep custom fields and option values in sync so summary/export payloads
    // match what the user sees, even before they edit the text fields.
    if (_options.resolution == ExportResolution.custom) {
      _options = _effectiveOptionsForExport();
    }
  }

  @override
  void dispose() {
    _customWidthController.dispose();
    _customHeightController.dispose();
    super.dispose();
  }

  int _sanitizeCustomDimension(
    String text,
    int? currentValue,
    int fallback,
  ) {
    final parsed = int.tryParse(text.trim());
    if (parsed != null && parsed > 0) return parsed;
    if (currentValue != null && currentValue > 0) return currentValue;
    return fallback;
  }

  ExportOptions _effectiveOptionsForExport() {
    if (_options.resolution != ExportResolution.custom) {
      return _options;
    }

    final width = _sanitizeCustomDimension(
      _customWidthController.text,
      _options.customWidth,
      1920,
    );
    final height = _sanitizeCustomDimension(
      _customHeightController.text,
      _options.customHeight,
      1080,
    );

    return _options.copyWith(
      customWidth: width,
      customHeight: height,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Icon(Icons.share_rounded, color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    Text(
                      l10n.exportTitle,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildSimpleModeCard(context, l10n),

                    const SizedBox(height: 16),

                    // Keep quick presets always visible for easy one-tap changes.
                    _buildQuickPresets(context, l10n),

                    if (_showCustomization) ...[
                      const SizedBox(height: 24),

                      // Format selection
                      _buildFormatSection(context, l10n),

                      const SizedBox(height: 20),

                      // Resolution selection
                      _buildResolutionSection(context, l10n),

                      const SizedBox(height: 20),

                      // Quality slider (for JPG/WebP)
                      if (_options.format != ExportFormat.png)
                        _buildQualitySection(context, l10n),

                      // Advanced options toggle
                      _buildAdvancedToggle(context, l10n),

                      if (_showAdvanced) ...[
                        const SizedBox(height: 16),
                        _buildAdvancedOptions(context, l10n),
                      ],
                    ],

                    const SizedBox(height: 24),

                    // Export info summary
                    _buildExportSummary(context, l10n),

                    const SizedBox(height: 100), // Space for button
                  ],
                ),
              ),

              // Export actions
              _buildExportActions(context, l10n),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSimpleModeCard(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:
            theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.flash_on_rounded, color: theme.colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _showCustomization
                  ? l10n.exportCustomizeModeHint
                  : l10n.exportSimpleModeHint,
              style: theme.textTheme.bodySmall,
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () {
              setState(() {
                _showCustomization = !_showCustomization;
                if (!_showCustomization) {
                  _showAdvanced = false;
                }
              });
            },
            child: Text(_showCustomization
                ? l10n.exportButtonSimple
                : l10n.exportButtonCustomize),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickPresets(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.exportQuickPresets,
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _QuickPresetChip(
                icon: Icons.share,
                label: l10n.exportPresetSocial,
                isSelected: _options == ExportPresets.socialShare,
                onTap: () =>
                    setState(() => _options = ExportPresets.socialShare),
              ),
              const SizedBox(width: 8),
              _QuickPresetChip(
                icon: Icons.high_quality,
                label: l10n.exportPresetHighQuality,
                isSelected: _options == ExportPresets.highQualityPng,
                onTap: () =>
                    setState(() => _options = ExportPresets.highQualityPng),
              ),
              const SizedBox(width: 8),
              _QuickPresetChip(
                icon: Icons.web,
                label: l10n.exportPresetWeb,
                isSelected: _options == ExportPresets.webOptimized,
                onTap: () =>
                    setState(() => _options = ExportPresets.webOptimized),
              ),
              const SizedBox(width: 8),
              _QuickPresetChip(
                icon: Icons.layers,
                label: l10n.exportPresetTransparent,
                isSelected: _options == ExportPresets.transparentOverlay,
                onTap: () =>
                    setState(() => _options = ExportPresets.transparentOverlay),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFormatSection(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.exportFormat,
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 12),
        SegmentedButton<ExportFormat>(
          segments: [
            ButtonSegment(
              value: ExportFormat.png,
              label: Text(l10n.exportFormatPng),
              icon: const Icon(Icons.image),
            ),
            ButtonSegment(
              value: ExportFormat.jpg,
              label: Text(l10n.exportFormatJpg),
              icon: const Icon(Icons.photo),
            ),
            ButtonSegment(
              value: ExportFormat.webp,
              label: Text(l10n.exportFormatWebp),
              icon: const Icon(Icons.web_asset),
            ),
          ],
          selected: {_options.format},
          onSelectionChanged: (selected) {
            setState(() {
              _options = _options.copyWith(
                format: selected.first,
                // Auto-disable transparency for JPG
                transparentBackground: selected.first == ExportFormat.jpg
                    ? false
                    : _options.transparentBackground,
              );
            });
          },
        ),
        const SizedBox(height: 8),
        _buildFormatHint(context, l10n),
      ],
    );
  }

  Widget _buildFormatHint(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    String hint;

    switch (_options.format) {
      case ExportFormat.png:
        hint = l10n.exportFormatHintPng;
        break;
      case ExportFormat.jpg:
        hint = l10n.exportFormatHintJpg;
        break;
      case ExportFormat.webp:
        hint = l10n.exportFormatHintWebp;
        break;
    }

    return Text(
      hint,
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
      ),
    );
  }

  Widget _buildResolutionSection(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.exportResolution,
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ExportResolution.values.map((resolution) {
            return ChoiceChip(
              label: Text(resolution.displayName),
              selected: _options.resolution == resolution,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    if (resolution == ExportResolution.custom) {
                      _options = _effectiveOptionsForExport().copyWith(
                        resolution: ExportResolution.custom,
                      );
                    } else {
                      _options = _options.copyWith(resolution: resolution);
                    }
                  });
                }
              },
            );
          }).toList(),
        ),
        if (_options.resolution == ExportResolution.custom) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _customWidthController,
                  decoration: InputDecoration(
                    labelText: l10n.exportWidth,
                    suffixText: 'px',
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final width = int.tryParse(value);
                    if (width != null && width > 0) {
                      setState(() {
                        _options = _options.copyWith(customWidth: width);
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.close, size: 16),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _customHeightController,
                  decoration: InputDecoration(
                    labelText: l10n.exportHeight,
                    suffixText: 'px',
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final height = int.tryParse(value);
                    if (height != null && height > 0) {
                      setState(() {
                        _options = _options.copyWith(customHeight: height);
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildQualitySection(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.exportQuality,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            Text(
              '${_options.quality}%',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Slider(
          value: _options.quality.toDouble(),
          min: 50,
          max: 100,
          divisions: 10,
          label: '${_options.quality}%',
          onChanged: (value) {
            setState(() {
              _options = _options.copyWith(quality: value.round());
            });
          },
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildAdvancedToggle(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => setState(() => _showAdvanced = !_showAdvanced),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Text(
              l10n.exportAdvancedOptions,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const Spacer(),
            Icon(
              _showAdvanced ? Icons.expand_less : Icons.expand_more,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedOptions(BuildContext context, AppLocalizations l10n) {
    return Column(
      children: [
        // Transparent background (only for PNG/WebP)
        if (_options.format != ExportFormat.jpg)
          SwitchListTile(
            title: Text(l10n.exportTransparentBg),
            subtitle: Text(l10n.exportTransparentBgHint),
            value: _options.transparentBackground,
            onChanged: (value) {
              setState(() {
                _options = _options.copyWith(transparentBackground: value);
              });
            },
          ),

        // Embed metadata
        SwitchListTile(
          title: Text(l10n.exportEmbedMetadata),
          subtitle: Text(l10n.exportEmbedMetadataHint),
          value: _options.embedMetadata,
          onChanged: (value) {
            setState(() {
              _options = _options.copyWith(embedMetadata: value);
            });
          },
        ),
      ],
    );
  }

  Widget _buildExportSummary(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final effectiveOptions = _effectiveOptionsForExport();
    final dims = effectiveOptions.resolution.dimensions;

    String resolutionText;
    if (effectiveOptions.resolution == ExportResolution.custom) {
      final w = effectiveOptions.customWidth ?? 1920;
      final h = effectiveOptions.customHeight ?? 1080;
      resolutionText = '$w×$h';
    } else if (dims != null) {
      resolutionText = '${dims.$1}×${dims.$2}';
    } else {
      resolutionText = l10n.exportScreenResolution;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.exportSummary,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _SummaryRow(
            icon: Icons.photo_size_select_large,
            label: l10n.exportResolution,
            value: resolutionText,
          ),
          const SizedBox(height: 8),
          _SummaryRow(
            icon: Icons.image,
            label: l10n.exportFormat,
            value: effectiveOptions.format.displayName,
          ),
          if (effectiveOptions.format != ExportFormat.png) ...[
            const SizedBox(height: 8),
            _SummaryRow(
              icon: Icons.tune,
              label: l10n.exportQuality,
              value: '${effectiveOptions.quality}%',
            ),
          ],
          if (effectiveOptions.transparentBackground) ...[
            const SizedBox(height: 8),
            _SummaryRow(
              icon: Icons.layers,
              label: l10n.exportTransparentBg,
              value: '✓',
            ),
          ],
          if (effectiveOptions.embedMetadata) ...[
            const SizedBox(height: 8),
            _SummaryRow(
              icon: Icons.info_outline,
              label: l10n.exportEmbedMetadata,
              value: '✓',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExportActions(BuildContext context, AppLocalizations l10n) {
    final effectiveOptions = _effectiveOptionsForExport();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                key: const ValueKey('exportSaveButton'),
                onPressed: () {
                  Navigator.of(context).pop(
                    ExportSheetSubmission(
                      options: effectiveOptions,
                      action: ExportAction.saveOnly,
                    ),
                  );
                },
                icon: const Icon(Icons.save_alt_rounded),
                label: Text(l10n.exportNow),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                key: const ValueKey('exportShareButton'),
                onPressed: () {
                  Navigator.of(context).pop(
                    ExportSheetSubmission(
                      options: effectiveOptions,
                      action: ExportAction.saveAndShare,
                    ),
                  );
                },
                icon: const Icon(Icons.share_rounded),
                label: Text(l10n.share),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickPresetChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _QuickPresetChip({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      button: true,
      selected: isSelected,
      label: isSelected
          ? '$label export preset, selected'
          : '$label export preset',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primaryContainer
                  : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(color: theme.colorScheme.primary, width: 2)
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
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

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

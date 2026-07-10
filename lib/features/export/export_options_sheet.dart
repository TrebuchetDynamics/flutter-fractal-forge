import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/models/export_options.dart';
import 'package:flutter_fractals/core/services/export/export_service.dart';
import 'package:flutter_fractals/features/export/custom_export_dimensions.dart';
import 'package:flutter_fractals/features/export/export_actions.dart';
import 'package:flutter_fractals/features/export/export_resolution_summary.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_fractals/shared/widgets/app_bottom_sheet.dart';
import 'package:flutter_fractals/shared/widgets/sheet_section_label.dart';

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
  late TextEditingController _quoteController;
  bool _showAdvanced = false;
  bool _showCustomization = false;

  @override
  void initState() {
    super.initState();
    _options = widget.initialOptions;
    _customWidthController = TextEditingController(
      text: _options.customWidth?.toString() ??
          defaultCustomExportWidth.toString(),
    );
    _customHeightController = TextEditingController(
      text: _options.customHeight?.toString() ??
          defaultCustomExportHeight.toString(),
    );
    _quoteController = TextEditingController(text: _options.quoteText ?? '');

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
    _quoteController.dispose();
    super.dispose();
  }

  ExportOptions _optionsWithCustomFields() {
    return withResolvedCustomExportDimensions(
      options: _options,
      widthText: _customWidthController.text,
      heightText: _customHeightController.text,
    );
  }

  ExportOptions _effectiveOptionsForExport() {
    final quote = _quoteController.text.trim();
    final options = _options.copyWith(quoteText: quote.isEmpty ? null : quote);
    if (options.resolution != ExportResolution.custom) {
      return options;
    }

    return withResolvedCustomExportDimensions(
      options: options,
      widthText: _customWidthController.text,
      heightText: _customHeightController.text,
    );
  }

  ExportFormat _effectiveFormatForExport(ExportOptions options) {
    return const ExportService().resolveEffectiveFormat(options.format);
  }

  String _formatSummaryValue(ExportOptions options, AppLocalizations l10n) {
    final effectiveFormat = _effectiveFormatForExport(options);
    if (effectiveFormat != options.format) {
      return '${effectiveFormat.displayName} (${l10n.exportFormatFallbackPng})';
    }
    return effectiveFormat.displayName;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppDraggableBottomSheet(
      initialChildSize: 0.82,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      childrenBuilder: (context, scrollController) => [
        AppBottomSheetHeader(
          icon: Icons.ios_share_rounded,
          title: l10n.exportTitle,
          onClose: () => Navigator.of(context).maybePop(),
        ),
        const Divider(height: 1),
        const SizedBox(height: 12),
        Expanded(
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _buildSimpleModeCard(context, l10n),
              const SizedBox(height: 12),
              if (_showCustomization) ...[
                _buildQuoteSection(context, l10n),
                const SizedBox(height: 16),
                _buildFormatSection(context, l10n),
                const SizedBox(height: 16),
                _buildResolutionSection(context, l10n),
                const SizedBox(height: 16),
                if (_options.format != ExportFormat.png)
                  _buildQualitySection(context, l10n),
                _buildAdvancedToggle(context, l10n),
                if (_showAdvanced) ...[
                  const SizedBox(height: 12),
                  _buildAdvancedOptions(context, l10n),
                ],
                const SizedBox(height: 16),
              ],
              _buildQuickPresets(context, l10n),
              const SizedBox(height: 24),
              _buildExportSummary(context, l10n),
              const SizedBox(height: 100),
            ],
          ),
        ),
        _buildExportActions(context, l10n),
      ],
    );
  }

  Widget _buildSimpleModeCard(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final effectiveOptions = _effectiveOptionsForExport();
    final screenSize = MediaQuery.sizeOf(context);
    final resolutionText = ExportResolutionSummary.fromEffectiveOptions(
      options: effectiveOptions,
      screenWidth: screenSize.width,
      screenHeight: screenSize.height,
    ).label(screenResolutionLabel: l10n.exportScreenResolution);
    final planText = '${_formatSummaryValue(effectiveOptions, l10n)} • '
        '$resolutionText';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.ios_share_rounded,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      planText,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _showCustomization
                          ? l10n.exportCustomizeModeHint
                          : l10n.exportSimpleModeHint,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.68),
                      ),
                    ),
                  ],
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
          const SizedBox(height: 12),
          Text(
            l10n.exportSaveLocationHint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
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
          style: sheetSectionLabelStyle(theme),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final spacing = 8.0;
            final cardWidth = constraints.maxWidth >= 560
                ? (constraints.maxWidth - spacing) / 2
                : constraints.maxWidth;
            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                _QuickPresetCard(
                  icon: Icons.share,
                  label: l10n.exportPresetSocial,
                  details: _presetDetails(ExportPresets.socialShare, l10n),
                  width: cardWidth,
                  isSelected: _options == ExportPresets.socialShare,
                  onTap: () =>
                      setState(() => _options = ExportPresets.socialShare),
                ),
                _QuickPresetCard(
                  icon: Icons.high_quality,
                  label: l10n.exportPresetHighQuality,
                  details: _presetDetails(ExportPresets.highQualityPng, l10n),
                  width: cardWidth,
                  isSelected: _options == ExportPresets.highQualityPng,
                  onTap: () =>
                      setState(() => _options = ExportPresets.highQualityPng),
                ),
                _QuickPresetCard(
                  icon: Icons.web,
                  label: l10n.exportPresetWeb,
                  details: _presetDetails(ExportPresets.webOptimized, l10n),
                  width: cardWidth,
                  isSelected: _options == ExportPresets.webOptimized,
                  onTap: () =>
                      setState(() => _options = ExportPresets.webOptimized),
                ),
                _QuickPresetCard(
                  icon: Icons.layers,
                  label: l10n.exportPresetTransparent,
                  details:
                      _presetDetails(ExportPresets.transparentOverlay, l10n),
                  width: cardWidth,
                  isSelected: _options == ExportPresets.transparentOverlay,
                  onTap: () => setState(
                    () => _options = ExportPresets.transparentOverlay,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  String _presetDetails(ExportOptions options, AppLocalizations l10n) {
    final format = _formatSummaryValue(options, l10n);
    return '$format • ${options.resolution.displayName}';
  }

  Widget _buildQuoteSection(BuildContext context, AppLocalizations l10n) {
    return TextField(
      key: const ValueKey('exportQuoteTextField'),
      controller: _quoteController,
      minLines: 1,
      maxLines: 3,
      decoration: InputDecoration(
        labelText: l10n.exportQuoteOverlay,
        hintText: l10n.exportQuoteOverlayPlaceholder,
        helperText: l10n.exportQuoteOverlayHint,
        border: const OutlineInputBorder(),
      ),
      textInputAction: TextInputAction.newline,
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildFormatSection(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.exportFormat,
          style: sheetSectionLabelStyle(theme),
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
          style: sheetSectionLabelStyle(theme),
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
                      _options = _optionsWithCustomFields().copyWith(
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
              style: sheetSectionLabelStyle(theme),
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
              style: sheetSectionLabelStyle(theme),
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

        // Watermark — off by default; stamps the @FractalForge handle so
        // reshared images stay attributed to the community brand.
        SwitchListTile(
          title: Text(l10n.exportWatermark),
          subtitle: Text(l10n.exportWatermarkHint),
          value: _options.addWatermark,
          onChanged: (value) {
            setState(() {
              _options = _options.copyWith(
                addWatermark: value,
                watermarkText: value ? '@FractalForge' : null,
              );
            });
          },
        ),
      ],
    );
  }

  Widget _buildExportSummary(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final effectiveOptions = _effectiveOptionsForExport();
    final screenSize = MediaQuery.sizeOf(context);
    final resolutionText = ExportResolutionSummary.fromEffectiveOptions(
      options: effectiveOptions,
      screenWidth: screenSize.width,
      screenHeight: screenSize.height,
    ).label(screenResolutionLabel: l10n.exportScreenResolution);
    final effectiveFormat = _effectiveFormatForExport(effectiveOptions);

    final chips = <Widget>[
      _SummaryChip(
        icon: Icons.photo_size_select_large,
        label: l10n.exportResolution,
        value: resolutionText,
      ),
      _SummaryChip(
        icon: Icons.image,
        label: l10n.exportFormat,
        value: _formatSummaryValue(effectiveOptions, l10n),
      ),
      if (effectiveFormat != ExportFormat.png)
        _SummaryChip(
          icon: Icons.tune,
          label: l10n.exportQuality,
          value: '${effectiveOptions.quality}%',
        ),
      if (effectiveOptions.transparentBackground)
        _SummaryChip(
          icon: Icons.layers,
          label: l10n.exportTransparentBg,
          value: '✓',
        ),
      if (effectiveOptions.embedMetadata)
        _SummaryChip(
          icon: Icons.info_outline,
          label: l10n.exportEmbedMetadata,
          value: '✓',
        ),
      if (effectiveOptions.quoteText?.isNotEmpty == true)
        _SummaryChip(
          icon: Icons.format_quote,
          label: l10n.exportQuoteOverlay,
          value: '✓',
        ),
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.14),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.exportSummary,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: chips),
          if (effectiveFormat != effectiveOptions.format) ...[
            const SizedBox(height: 12),
            Text(
              l10n.exportFormatHintWebp,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.68),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExportActions(BuildContext context, AppLocalizations l10n) {
    final effectiveOptions = _effectiveOptionsForExport();
    final canSaveAndShare = ExportActionAvailability.canSaveAndShare(
      isWeb: kIsWeb,
    );
    final canSetWallpaper = ExportActionAvailability.canSetWallpaper(
      isWeb: kIsWeb,
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color:
                Theme.of(context).colorScheme.outline.withValues(alpha: 0.12),
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Semantics(
                    button: true,
                    label: l10n.exportActionSaveImage,
                    hint: l10n.exportSaveLocationHint,
                    child: FilledButton.icon(
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
                      label: Text(l10n.exportActionSaveImage),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Semantics(
                    button: true,
                    enabled: canSaveAndShare,
                    label: l10n.exportActionSaveAndShare,
                    hint: l10n.exportSaveLocationHint,
                    child: OutlinedButton.icon(
                      key: const ValueKey('exportShareButton'),
                      onPressed: canSaveAndShare
                          ? () {
                              Navigator.of(context).pop(
                                ExportSheetSubmission(
                                  options: effectiveOptions,
                                  action: ExportAction.saveAndShare,
                                ),
                              );
                            }
                          : null,
                      icon: const Icon(Icons.share_rounded),
                      label: Text(l10n.exportActionSaveAndShare),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: Semantics(
                button: true,
                enabled: canSetWallpaper,
                label: l10n.wallpaperTitle,
                child: OutlinedButton.icon(
                  key: const ValueKey('exportWallpaperButton'),
                  onPressed: canSetWallpaper
                      ? () {
                          Navigator.of(context).pop(
                            ExportSheetSubmission(
                              options: effectiveOptions,
                              action: ExportAction.setWallpaper,
                            ),
                          );
                        }
                      : null,
                  icon: const Icon(Icons.wallpaper_rounded),
                  label: Text(l10n.wallpaperTitle),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickPresetCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String details;
  final double width;
  final bool isSelected;
  final VoidCallback onTap;

  const _QuickPresetCard({
    required this.icon,
    required this.label,
    required this.details,
    required this.width,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedColor = theme.colorScheme.primary;
    final foreground = isSelected
        ? selectedColor
        : theme.colorScheme.onSurface.withValues(alpha: 0.78);

    return Semantics(
      button: true,
      selected: isSelected,
      label: isSelected
          ? '$label export preset, $details, selected'
          : '$label export preset, $details',
      child: SizedBox(
        width: width,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            constraints: const BoxConstraints(minHeight: 78),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? selectedColor
                    : theme.colorScheme.outline.withValues(alpha: 0.14),
                width: isSelected ? 1.6 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: (isSelected
                            ? theme.colorScheme.primaryContainer
                            : theme.colorScheme.surfaceContainerHighest)
                        .withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(icon, size: 20, color: foreground),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: foreground,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        details,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.62),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.check_circle_rounded,
                      size: 18, color: selectedColor),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SummaryChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color:
            theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.56),
          ),
          const SizedBox(width: 6),
          Text(
            '$label ',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.62),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

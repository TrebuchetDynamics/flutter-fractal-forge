import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fractals/core/services/export/share_service.dart';
import 'package:flutter_fractals/core/services/platform/haptic_service.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/core/widgets/animated_widgets.dart';
import 'package:flutter_fractals/shared/widgets/app_bottom_sheet.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_fractals/shared/widgets/app_feedback_snack_bar.dart';

class ExportOverlay extends StatelessWidget {
  final double? progress;
  final AppLocalizations l10n;
  final VoidCallback? onCancel;

  const ExportOverlay({
    super.key,
    required this.progress,
    required this.l10n,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        color: AppColors.background.withValues(alpha: 0.7),
        child: Center(
          child: FadeIn(
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.xl),
                border:
                    Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.downloading_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    l10n.exporting,
                    style: AppTypography.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SizedBox(
                    width: 200,
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 6,
                            backgroundColor: AppColors.surfaceVariant,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.primary),
                          ),
                        ),
                        if (progress != null) ...[
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            '${(progress! * 100).round()}%',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (onCancel != null) ...[
                    const SizedBox(height: AppSpacing.lg),
                    TextButton.icon(
                      key: const ValueKey('cancelActiveExportButton'),
                      onPressed: onCancel,
                      icon: const Icon(Icons.close_rounded),
                      label: Text(l10n.actionCancel),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Shares the original interactive view link, never the preview image.
class ShareSheet extends StatefulWidget {
  final Uri uri;
  final String fractalName;
  final ShareTextCallback? shareText;

  /// Actual captured artwork. A missing capture is presented honestly.
  final Uint8List? previewBytes;

  const ShareSheet({
    super.key,
    required this.uri,
    required this.fractalName,
    this.shareText,
    this.previewBytes,
  });

  @override
  State<ShareSheet> createState() => _ShareSheetState();
}

class _ShareSheetState extends State<ShareSheet> {
  bool _showFullLink = false;
  bool _busy = false;

  Future<void> _send({required bool copy}) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final route = ModalRoute.of(context);
    // Display compaction must never change the clipboard or native payload.
    final linkText = widget.uri.toString();
    HapticService.medium();
    setState(() => _busy = true);
    try {
      if (copy) {
        await Clipboard.setData(ClipboardData(text: linkText));
      } else {
        await (widget.shareText ?? const AppShareService().shareText)(
          l10n.shareMessage(widget.fractalName, linkText),
          subject: l10n.shareSubject(widget.fractalName),
        );
      }
      if (!mounted || route?.isCurrent == false) return;
      navigator.pop();
      if (copy && messenger.mounted) {
        messenger.showSnackBar(
            appFeedbackSnackBar(message: l10n.linkCopied, success: true));
      }
    } catch (error) {
      if (!mounted || route?.isCurrent == false) return;
      messenger.showSnackBar(appFeedbackSnackBar(
        message: l10n.exportFailed(error.toString()),
        success: false,
      ));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final uri = widget.uri;
    final displayLink = '${uri.host}${uri.path}';
    final preview = widget.previewBytes;
    final actionStyle = ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
    return AppBottomSheet(
      maxHeightFactor: 0.85,
      children: [
        Flexible(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppBottomSheetHeader(
                  icon: Icons.link_rounded,
                  title: l10n.shareViewLinkTitle,
                  onClose: () => Navigator.of(context).pop(),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (preview != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.memory(
                            preview,
                            height: 160,
                            fit: BoxFit.cover,
                            semanticLabel: widget.fractalName,
                            errorBuilder: (_, __, ___) =>
                                _previewFallback(l10n),
                          ),
                        )
                      else
                        _previewFallback(l10n),
                      const SizedBox(height: AppSpacing.md),
                      Text(widget.fractalName,
                          style: theme.textTheme.titleMedium),
                      const SizedBox(height: AppSpacing.sm),
                      Text(l10n.shareViewLinkDescription,
                          style: theme.textTheme.bodyMedium),
                      const SizedBox(height: AppSpacing.md),
                      Text(displayLink,
                          style: theme.textTheme.labelLarge,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: AppSpacing.sm),
                      TextButton.icon(
                        style: actionStyle,
                        onPressed: () =>
                            setState(() => _showFullLink = !_showFullLink),
                        icon: Icon(_showFullLink
                            ? Icons.expand_less
                            : Icons.expand_more),
                        label: Semantics(
                          expanded: _showFullLink,
                          child: Text(_showFullLink
                              ? l10n.shareFullLinkHide
                              : l10n.shareFullLinkShow),
                        ),
                      ),
                      if (_showFullLink)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.md),
                          child: SelectableText(uri.toString(),
                              style: theme.textTheme.bodyMedium),
                        ),
                      const SizedBox(height: AppSpacing.md),
                      LayoutBuilder(builder: (context, constraints) {
                        // Stack equal-width actions before enlarged labels wrap.
                        final stacked = constraints.maxWidth < 340 ||
                            MediaQuery.textScalerOf(context).scale(14) > 20;
                        final actionWidth = stacked
                            ? constraints.maxWidth
                            : (constraints.maxWidth - 12) / 2;
                        var actionHeight = 48.0;
                        for (final label in [
                          l10n.shareViewLinkCopy,
                          l10n.shareViewLinkShare
                        ]) {
                          final painter = TextPainter(
                            text: TextSpan(
                                text: label, style: theme.textTheme.labelLarge),
                            textDirection: Directionality.of(context),
                            textScaler: MediaQuery.textScalerOf(context),
                          )..layout(
                              maxWidth:
                                  (actionWidth - 64).clamp(1, double.infinity));
                          if (painter.height + 24 > actionHeight)
                            actionHeight = painter.height + 24;
                          painter.dispose();
                        }
                        final matchingStyle = actionStyle.copyWith(
                          minimumSize:
                              WidgetStatePropertyAll(Size(48, actionHeight)),
                          textStyle: WidgetStatePropertyAll(
                              theme.textTheme.labelLarge),
                        );
                        final copy = OutlinedButton.icon(
                          style: matchingStyle,
                          onPressed: _busy ? null : () => _send(copy: true),
                          icon: const Icon(Icons.copy_rounded),
                          label: Text(l10n.shareViewLinkCopy),
                        );
                        final share = FilledButton.icon(
                          style: matchingStyle,
                          onPressed: _busy ? null : () => _send(copy: false),
                          icon: const Icon(Icons.share_rounded),
                          label: Text(l10n.shareViewLinkShare),
                        );
                        return stacked
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                    copy,
                                    const SizedBox(height: 12),
                                    share
                                  ])
                            : Row(children: [
                                Expanded(child: copy),
                                const SizedBox(width: 12),
                                Expanded(child: share)
                              ]);
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _previewFallback(AppLocalizations l10n) => Text(
        l10n.shareViewLinkPreviewUnavailable,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      );
}

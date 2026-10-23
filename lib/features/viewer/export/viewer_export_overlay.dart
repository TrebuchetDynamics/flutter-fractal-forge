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

/// Bottom sheet for sharing fractal configuration via deep link.
class ShareSheet extends StatelessWidget {
  final Uri uri;
  final String fractalName;
  final ShareTextCallback? shareText;

  const ShareSheet({
    super.key,
    required this.uri,
    required this.fractalName,
    this.shareText,
  });

  Future<void> _share(BuildContext context, AppLocalizations l10n) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final linkText = uri.toString();

    try {
      await (shareText ?? const AppShareService().shareText)(
        l10n.shareMessage(fractalName, linkText),
        subject: l10n.shareSubject(fractalName),
      );
      navigator.pop();
    } catch (error) {
      messenger.showSnackBar(
        appFeedbackSnackBar(
          message: l10n.exportFailed(error.toString()),
          success: false,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final linkText = uri.toString();

    return AppBottomSheet(
      children: [
        AppBottomSheetHeader(
          icon: Icons.share_rounded,
          title: l10n.shareTitle,
          onClose: () => Navigator.of(context).pop(),
        ),
        const Divider(height: 1),
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.shareSubtitle(fractalName),
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SelectableText(linkText,
                      style: Theme.of(context).textTheme.bodyMedium),
                ),
                const SizedBox(height: AppSpacing.lg),
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.sm,
                  children: [
                    OutlinedButton.icon(
                      icon: const Icon(Icons.copy_rounded),
                      label: Text(l10n.actionCopy),
                      onPressed: () {
                        HapticService.medium();
                        Clipboard.setData(ClipboardData(text: linkText));
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.linkCopied),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                    FilledButton.icon(
                      icon: const Icon(Icons.share_rounded),
                      label: Text(l10n.actionShare),
                      onPressed: () {
                        HapticService.medium();
                        _share(context, l10n);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_fractals/core/services/accessibility_service.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/core/widgets/accessibility_widgets.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';

/// Settings screen for accessibility options.
///
/// Allows users to configure:
/// - High contrast mode
/// - Reduced motion
/// - Large touch targets
///
/// Settings are persisted and take effect immediately.
class AccessibilitySettingsScreen extends StatelessWidget {
  const AccessibilitySettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final accessibility = context.watch<AccessibilityService>();
    final isScreenReaderActive = context.isScreenReaderActive;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.accessibilityTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: l10n.semanticBackButton,
        ),
      ),
      body: AccessibleGroup(
        label: l10n.accessibilityTitle,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            // Screen reader status (informational)
            if (isScreenReaderActive)
              _InfoCard(
                icon: Icons.accessibility_new,
                text: l10n.accessibilityScreenReaderActive,
              ),

            const SizedBox(height: AppSpacing.lg),

            // High Contrast Mode
            _SettingTile(
              icon: Icons.contrast,
              title: l10n.accessibilityHighContrast,
              subtitle: l10n.accessibilityHighContrastHint,
              value: accessibility.highContrastEnabled,
              onChanged: (value) => accessibility.setHighContrast(value),
            ),

            const SizedBox(height: AppSpacing.md),

            // Reduced Motion
            _SettingTile(
              icon: Icons.animation,
              title: l10n.accessibilityReducedMotion,
              subtitle: l10n.accessibilityReducedMotionHint,
              value: accessibility.reducedMotionEnabled,
              onChanged: (value) => accessibility.setReducedMotion(value),
            ),

            const SizedBox(height: AppSpacing.md),

            // Large Touch Targets
            _SettingTile(
              icon: Icons.touch_app,
              title: l10n.accessibilityLargeTargets,
              subtitle: l10n.accessibilityLargeTargetsHint,
              value: accessibility.largeTargetsEnabled,
              onChanged: (value) => accessibility.setLargeTargets(value),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // System settings hint
            _SystemSettingsHint(),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoCard({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: text,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppColors.primary,
              size: 24,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                text,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final semanticLabel = value
        ? l10n.semanticToggleOn(title)
        : l10n.semanticToggleOff(title);

    return Semantics(
      label: semanticLabel,
      hint: subtitle,
      toggled: value,
      enabled: true,
      onTap: () => onChanged(!value),
      child: GestureDetector(
        onTap: () => onChanged(!value),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: value
                ? AppColors.primary.withOpacity(0.1)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(
              color: value
                  ? AppColors.primary.withOpacity(0.4)
                  : AppColors.border.withOpacity(0.5),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: value
                      ? AppColors.primary.withOpacity(0.2)
                      : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
                ),
                child: Icon(
                  icon,
                  color: value ? AppColors.primary : AppColors.textMuted,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.titleMedium.copyWith(
                        color: value ? AppColors.primary : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              // Use semantic-excluded switch since we handle it at container level
              ExcludeSemantics(
                child: Switch(
                  value: value,
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SystemSettingsHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final prefersReducedMotion = context.shouldReduceMotion;
    final prefersHighContrast = context.prefersHighContrast;

    if (!prefersReducedMotion && !prefersHighContrast) {
      return const SizedBox.shrink();
    }

    final hints = <String>[];
    if (prefersReducedMotion) {
      hints.add('Reduced motion is enabled at system level');
    }
    if (prefersHighContrast) {
      hints.add('High contrast is enabled at system level');
    }

    return Semantics(
      container: true,
      label: hints.join('. '),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant.withOpacity(0.5),
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: AppColors.textMuted,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                hints.join('\n'),
                style: AppTypography.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

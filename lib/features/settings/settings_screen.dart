import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_fractals/core/app_version.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/core/services/platform/accessibility_service.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_fractals/shared/widgets/app_bottom_sheet.dart';
import 'package:flutter_fractals/features/settings/accessibility_settings_screen.dart';
import 'package:flutter_fractals/features/formulas/frm_formula_screen.dart';

/// Main settings screen with navigation to accessibility and other options.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabSettings)),
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.md),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.md),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _SettingsTile(
                  icon: Icons.accessibility_new_rounded,
                  title: l10n.accessibilityTitle,
                  subtitle: l10n.settingsAccessibilitySubtitle,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AccessibilitySettingsScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                _SettingsTile(
                  icon: Icons.palette_outlined,
                  title: l10n.paramColorScheme,
                  subtitle: l10n.settingsPaletteSubtitle,
                  onTap: () {
                    _showThemeSelector(context);
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                _SettingsTile(
                  icon: Icons.functions_rounded,
                  title: l10n.settingsFormulaLab,
                  subtitle: l10n.settingsFormulaLabSubtitle,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const FrmFormulaScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                _SettingsTile(
                  icon: Icons.language_rounded,
                  title: l10n.settingsLanguage,
                  subtitle: 'English / Español',
                  onTap: () {
                    // TODO: Implement language selection
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                _SettingsTile(
                  icon: Icons.info_outline_rounded,
                  title: l10n.settingsAbout,
                  subtitle: l10n.settingsVersion(kAppVersion),
                  onTap: () {
                    _showAboutDialog(context);
                  },
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _showThemeSelector(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final accessibility = context.read<AccessibilityService>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => AppBottomSheet(
        maxHeightFactor: 0.56,
        children: [
          AppBottomSheetHeader(
            icon: Icons.palette_outlined,
            title: l10n.settingsColorTheme,
            subtitle: l10n.settingsColorThemeSubtitle,
            onClose: () => Navigator.pop(sheetContext),
          ),
          const Divider(height: 1, color: AppColors.divider),
          // Flexible and scrollable, like every other sheet body: as a plain
          // fixed child this Column overflowed the 0.56 height factor by 192px,
          // because three theme cards plus the cancel button exceed it and
          // AppBottomSheet gives its children no scroll region of its own.
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ThemeOption(
                    title: AppThemeMode.dark.displayName,
                    subtitle: AppThemeMode.dark.description,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0A0A12), Color(0xFF7C4DFF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    isSelected: accessibility.themeMode == AppThemeMode.dark,
                    onTap: () {
                      accessibility.setThemeMode(AppThemeMode.dark);
                      Navigator.pop(sheetContext);
                    },
                  ),
                  const SizedBox(height: 12),
                  _ThemeOption(
                    title: AppThemeMode.oled.displayName,
                    subtitle: AppThemeMode.oled.description,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF000000), Color(0xFF7C4DFF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    isSelected: accessibility.themeMode == AppThemeMode.oled,
                    onTap: () {
                      accessibility.setThemeMode(AppThemeMode.oled);
                      Navigator.pop(sheetContext);
                    },
                  ),
                  const SizedBox(height: 12),
                  _ThemeOption(
                    title: AppThemeMode.highContrast.displayName,
                    subtitle: AppThemeMode.highContrast.description,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF000000), Color(0xFFFFFF00)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    isSelected:
                        accessibility.themeMode == AppThemeMode.highContrast,
                    onTap: () {
                      accessibility.setThemeMode(AppThemeMode.highContrast);
                      Navigator.pop(sheetContext);
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      child: Text(l10n.actionCancel),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AppDialog(
        icon: Icons.blur_circular_rounded,
        title: 'Fractal Forge',
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.settingsVersion(kAppVersion),
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.settingsAboutBlurb,
              // textSecondary, not textMuted: prose at 12px measured 3.70:1
              // against the dialog surface, under the 4.5 AA floor.
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.actionClose),
          ),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final Gradient gradient;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                // Theme preview
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.border,
                      width: 1,
                    ),
                  ),
                  child: isSelected
                      ? const Center(
                          child: Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                // Theme info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceVariant,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

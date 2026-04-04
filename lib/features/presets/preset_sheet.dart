import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_fractals/core/models/fractal_preset.dart';
import 'package:flutter_fractals/core/services/preset_store.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/core/widgets/animated_widgets.dart';
import 'package:flutter_fractals/features/renderer/providers/fractal_provider.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_fractals/shared/widgets/app_bottom_sheet.dart';

class PresetSheet extends StatefulWidget {
  /// Optional callback when batch export is requested.
  final VoidCallback? onBatchExport;

  const PresetSheet({Key? key, this.onBatchExport}) : super(key: key);

  @override
  State<PresetSheet> createState() => _PresetSheetState();
}

class _PresetSheetState extends State<PresetSheet> {
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _saving = false;
  bool _isInputFocused = false;
  Future<List<FractalPreset>>? _userPresetsFuture;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() {
      if (mounted) setState(() {});
    });
    _focusNode.addListener(() {
      setState(() => _isInputFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<FractalController>();
    final presetStore = context.read<PresetStore>();
    final l10n = AppLocalizations.of(context)!;

    _userPresetsFuture ??= presetStore.loadUserPresets(controller.module.id);

    return AppBottomSheet(
      maxHeightFactor: 0.85,
      children: [
        AppBottomSheetHeader(
          icon: Icons.bookmark_rounded,
          iconGradient: LinearGradient(
            colors: [
              AppColors.secondary.withValues(alpha: 0.8),
              AppColors.secondaryDark,
            ],
          ),
          title: l10n.presetsTitle,
          subtitle: controller.module.displayName(l10n),
          onClose: () => Navigator.of(context).pop(),
        ),
        const Divider(height: 1, color: AppColors.divider),
        // Scrollable content
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Save new preset section
                SectionHeader(title: l10n.savePreset),
                const SizedBox(height: AppSpacing.sm),
                FadeIn(
                  child: AnimatedContainer(
                    duration: AppAnimations.normal,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                      borderRadius:
                          BorderRadius.circular(AppSpacing.cardRadius),
                      border: Border.all(
                        color: _isInputFocused
                            ? AppColors.primary.withValues(alpha: 0.4)
                            : AppColors.border.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        AnimatedContainer(
                          duration: AppAnimations.normal,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius:
                                BorderRadius.circular(AppSpacing.inputRadius),
                            border: Border.all(
                              color: _isInputFocused
                                  ? AppColors.primary.withValues(alpha: 0.6)
                                  : AppColors.border.withValues(alpha: 0.4),
                              width: _isInputFocused ? 1.5 : 1,
                            ),
                          ),
                          child: TextField(
                            controller: _nameController,
                            focusNode: _focusNode,
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textPrimary,
                            ),
                            decoration: InputDecoration(
                              hintText: l10n.presetNameHint,
                              hintStyle: AppTypography.bodyMedium.copyWith(
                                color: AppColors.textMuted,
                              ),
                              prefixIcon: Icon(
                                Icons.edit_rounded,
                                size: 20,
                                color: _isInputFocused
                                    ? AppColors.primary
                                    : AppColors.textMuted,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.lg,
                                vertical: AppSpacing.md,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        SizedBox(
                          width: double.infinity,
                          child: GradientButton(
                            onPressed:
                                (_saving || _nameController.text.trim().isEmpty)
                                    ? null
                                    : () => _savePreset(
                                        context, controller, presetStore, l10n),
                            gradient: LinearGradient(
                              colors: [
                                AppColors.secondary.withValues(alpha: 0.9),
                                AppColors.secondaryDark,
                              ],
                            ),
                            child: _saving
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.save_rounded, size: 20),
                                      const SizedBox(width: AppSpacing.sm),
                                      Text(l10n.savePreset),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Built-in presets
                SectionHeader(title: l10n.builtInPresets),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: controller.module.builtInPresets
                      .asMap()
                      .entries
                      .map((entry) {
                    return StaggeredItem(
                      index: entry.key,
                      itemDelay: AppAnimations.presetItemDelay,
                      child: _PresetChip(
                        label: _presetName(context, entry.value),
                        icon: Icons.auto_awesome_rounded,
                        isBuiltIn: true,
                        onTap: () {
                          controller.applyPreset(entry.value);
                          Navigator.of(context).pop();
                        },
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.xl),

                // User presets
                SectionHeader(title: l10n.userPresets),
                const SizedBox(height: AppSpacing.sm),
                FutureBuilder<List<FractalPreset>>(
                  future: _userPresetsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Padding(
                        padding:
                            const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Text(
                              l10n.loadingPresets,
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    if (snapshot.hasError) {
                      return FadeIn(
                        child: _ErrorState(
                          message: l10n.presetsLoadFailed,
                          onRetry: () {
                            setState(() {
                              _userPresetsFuture = presetStore
                                  .loadUserPresets(controller.module.id);
                            });
                          },
                          l10n: l10n,
                        ),
                      );
                    }
                    final presets = snapshot.data ?? [];
                    if (presets.isEmpty) {
                      return FadeIn(
                        child: _EmptyUserPresets(l10n: l10n),
                      );
                    }
                    return Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: presets.asMap().entries.map((entry) {
                        final preset = entry.value;
                        return StaggeredItem(
                          index: entry.key,
                          itemDelay: AppAnimations.presetItemDelay,
                          child: _UserPresetChip(
                            label: preset.name,
                            onTap: () {
                              controller.applyPreset(preset);
                              Navigator.of(context).pop();
                            },
                            onDelete: () => _confirmDeletePreset(
                              context,
                              controller,
                              presetStore,
                              preset,
                              l10n,
                            ),
                            onRename: () => _showRenameDialog(
                              context,
                              controller,
                              presetStore,
                              preset,
                              l10n,
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
                SizedBox(
                    height:
                        MediaQuery.of(context).padding.bottom + AppSpacing.lg),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _savePreset(
    BuildContext context,
    FractalController controller,
    PresetStore presetStore,
    AppLocalizations l10n,
  ) async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.presetNameRequired)),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final preset = FractalPreset(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        moduleId: controller.module.id,
        name: name,
        params: Map<String, Object>.from(controller.params),
        view: controller.view,
        createdAt: DateTime.now(),
      );
      await presetStore.saveUserPreset(preset);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: AppColors.success),
                const SizedBox(width: AppSpacing.sm),
                Text(l10n.presetSaved),
              ],
            ),
          ),
        );
      }
      _nameController.clear();
      setState(() {
        _userPresetsFuture = presetStore.loadUserPresets(controller.module.id);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.presetSaveFailed(e.toString()))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _confirmDeletePreset(
    BuildContext context,
    FractalController controller,
    PresetStore presetStore,
    FractalPreset preset,
    AppLocalizations l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          l10n.deletePresetTitle,
          style:
              AppTypography.titleMedium.copyWith(color: AppColors.textPrimary),
        ),
        content: Text(
          l10n.deletePresetMessage(preset.name),
          style:
              AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.buttonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(l10n.buttonDelete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await presetStore.deleteUserPreset(preset.moduleId, preset.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.presetDeleted)),
        );
        setState(() {
          _userPresetsFuture =
              presetStore.loadUserPresets(controller.module.id);
        });
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.presetDeleteFailed)),
        );
      }
    }
  }

  Future<void> _showRenameDialog(
    BuildContext context,
    FractalController controller,
    PresetStore presetStore,
    FractalPreset preset,
    AppLocalizations l10n,
  ) async {
    final renameController = TextEditingController(text: preset.name);
    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          l10n.renamePresetTitle,
          style:
              AppTypography.titleMedium.copyWith(color: AppColors.textPrimary),
        ),
        content: TextField(
          controller: renameController,
          autofocus: true,
          style:
              AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: l10n.renamePresetHint,
            hintStyle:
                AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
          ),
          onSubmitted: (v) {
            final trimmed = v.trim();
            if (trimmed.isNotEmpty) Navigator.of(ctx).pop(trimmed);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.buttonCancel),
          ),
          TextButton(
            onPressed: () {
              final trimmed = renameController.text.trim();
              if (trimmed.isNotEmpty) Navigator.of(ctx).pop(trimmed);
            },
            child: Text(l10n.buttonSave),
          ),
        ],
      ),
    );
    renameController.dispose();
    if (newName == null || newName.isEmpty) return;
    try {
      await presetStore.updatePreset(preset.moduleId, preset.id, name: newName);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.presetRenamed)),
        );
        setState(() {
          _userPresetsFuture =
              presetStore.loadUserPresets(controller.module.id);
        });
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.presetRenameFailed)),
        );
      }
    }
  }

  String _presetName(BuildContext context, FractalPreset preset) {
    final l10n = AppLocalizations.of(context)!;
    switch (preset.name) {
      case 'Default':
        return l10n.presetDefault;
      case 'Classic':
        return l10n.presetClassic;
      case 'Soft Glow':
        return l10n.presetSoftGlow;
      case 'Psychedelic':
        return l10n.presetPsychedelic;
      case 'Deep Bloom':
        return l10n.presetDeepBloom;
      default:
        return preset.name;
    }
  }
}

class _PresetChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isBuiltIn;
  final VoidCallback onTap;

  const _PresetChip({
    required this.label,
    required this.icon,
    required this.isBuiltIn,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      builder: (isPressed) => AnimatedContainer(
        duration: AppAnimations.normal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isPressed
              ? (isBuiltIn
                  ? AppColors.primary.withValues(alpha: 0.25)
                  : AppColors.secondary.withValues(alpha: 0.25))
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
          border: Border.all(
            color: isPressed
                ? (isBuiltIn
                    ? AppColors.primary.withValues(alpha: 0.6)
                    : AppColors.secondary.withValues(alpha: 0.6))
                : AppColors.border.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isPressed
                  ? (isBuiltIn ? AppColors.primary : AppColors.secondary)
                  : AppColors.textMuted,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                color: isPressed
                    ? (isBuiltIn ? AppColors.primary : AppColors.secondary)
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserPresetChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onRename;

  const _UserPresetChip({
    required this.label,
    required this.onTap,
    required this.onDelete,
    required this.onRename,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return PressableScale(
      onTap: onTap,
      builder: (isPressed) => AnimatedContainer(
        duration: AppAnimations.normal,
        padding: const EdgeInsets.only(
          left: AppSpacing.md,
          top: AppSpacing.sm,
          bottom: AppSpacing.sm,
          right: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isPressed
              ? AppColors.secondary.withValues(alpha: 0.25)
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
          border: Border.all(
            color: isPressed
                ? AppColors.secondary.withValues(alpha: 0.6)
                : AppColors.border.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bookmark_outline_rounded,
              size: 16,
              color: isPressed ? AppColors.secondary : AppColors.textMuted,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                color:
                    isPressed ? AppColors.secondary : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Tooltip(
              message: l10n.tooltipRenamePreset,
              child: InkWell(
                onTap: onRename,
                borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
                // WCAG 2.2 minimum 48x48px touch target
                child: Padding(
                  padding: const EdgeInsets.all(17),
                  child: Icon(
                    Icons.edit_outlined,
                    size: 14,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ),
            Tooltip(
              message: l10n.tooltipDeletePreset,
              child: InkWell(
                onTap: onDelete,
                borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
                // WCAG 2.2 minimum 48x48px touch target
                child: Padding(
                  padding: const EdgeInsets.all(17),
                  child: Icon(
                    Icons.close_rounded,
                    size: 14,
                    color: AppColors.textMuted,
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

class _EmptyUserPresets extends StatelessWidget {
  final AppLocalizations l10n;

  const _EmptyUserPresets({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.2),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.bookmark_add_rounded,
            size: 32,
            color: AppColors.textMuted.withValues(alpha: 0.6),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.noUserPresets,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final AppLocalizations l10n;

  const _ErrorState({
    required this.message,
    required this.onRetry,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodySmall.copyWith(color: AppColors.error),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: Text(l10n.actionRetry),
          ),
        ],
      ),
    );
  }
}

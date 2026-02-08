import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_fractals/core/models/fractal_preset.dart';
import 'package:flutter_fractals/core/services/preset_store.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/core/widgets/animated_widgets.dart';
import 'package:flutter_fractals/features/renderer/providers/fractal_provider.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';

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

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: AppSpacing.md),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.lg,
              AppSpacing.xl,
              AppSpacing.sm,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.secondary.withOpacity(0.8),
                        AppColors.secondaryDark,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.bookmark_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.presetsTitle,
                        style: AppTypography.headlineMedium,
                      ),
                      Text(
                        controller.module.displayName(l10n),
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.close_rounded,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
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
                        color: AppColors.surfaceVariant.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                        border: Border.all(
                          color: _isInputFocused
                              ? AppColors.primary.withOpacity(0.4)
                              : AppColors.border.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          AnimatedContainer(
                            duration: AppAnimations.normal,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
                              border: Border.all(
                                color: _isInputFocused
                                    ? AppColors.primary.withOpacity(0.6)
                                    : AppColors.border.withOpacity(0.4),
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
                              onPressed: (_saving || _nameController.text.trim().isEmpty)
                                  ? null
                                  : () => _savePreset(context, controller, presetStore, l10n),
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.secondary.withOpacity(0.9),
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
                    children: controller.module.builtInPresets.asMap().entries.map((entry) {
                      return StaggeredItem(
                        index: entry.key,
                        itemDelay: const Duration(milliseconds: 40),
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
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
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
                                _userPresetsFuture =
                                    presetStore.loadUserPresets(controller.module.id);
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
                          return StaggeredItem(
                            index: entry.key,
                            itemDelay: const Duration(milliseconds: 40),
                            child: _PresetChip(
                              label: entry.value.name,
                              icon: Icons.bookmark_outline_rounded,
                              isBuiltIn: false,
                              onTap: () {
                                controller.applyPreset(entry.value);
                                Navigator.of(context).pop();
                              },
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  SizedBox(height: MediaQuery.of(context).padding.bottom + AppSpacing.lg),
                ],
              ),
            ),
          ),
        ],
      ),
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
                const Icon(Icons.check_circle_rounded, color: AppColors.success),
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

class _PresetChip extends StatefulWidget {
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
  State<_PresetChip> createState() => _PresetChipState();
}

class _PresetChipState extends State<_PresetChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.fast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: AppAnimations.snappyCurve),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: AppAnimations.normal,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: _isPressed
                ? (widget.isBuiltIn
                    ? AppColors.primary.withOpacity(0.25)
                    : AppColors.secondary.withOpacity(0.25))
                : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
            border: Border.all(
              color: _isPressed
                  ? (widget.isBuiltIn
                      ? AppColors.primary.withOpacity(0.6)
                      : AppColors.secondary.withOpacity(0.6))
                  : AppColors.border.withOpacity(0.4),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 16,
                color: _isPressed
                    ? (widget.isBuiltIn ? AppColors.primary : AppColors.secondary)
                    : AppColors.textMuted,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                widget.label,
                style: AppTypography.labelMedium.copyWith(
                  color: _isPressed
                      ? (widget.isBuiltIn ? AppColors.primary : AppColors.secondary)
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
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
        color: AppColors.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(
          color: AppColors.border.withOpacity(0.2),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.bookmark_add_rounded,
            size: 32,
            color: AppColors.textMuted.withOpacity(0.6),
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
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(
          color: AppColors.error.withOpacity(0.3),
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

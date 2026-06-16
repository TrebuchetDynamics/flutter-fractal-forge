import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/core/widgets/animated_widgets.dart';
import 'package:flutter_fractals/features/history/history_entry.dart';
import 'package:flutter_fractals/features/history/history_provider.dart';
import 'package:flutter_fractals/features/renderer/providers/fractal_provider.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_fractals/shared/widgets/app_bottom_sheet.dart';
import 'package:intl/intl.dart';

/// A modal bottom sheet displaying exploration history and favorites.
///
/// Provides:
/// - Back/forward navigation buttons
/// - List of visited locations (history)
/// - List of saved favorites
/// - Ability to save current location as favorite
///
/// {@category Widgets}
class HistorySheet extends StatefulWidget {
  const HistorySheet({super.key});

  @override
  State<HistorySheet> createState() => _HistorySheetState();
}

class _HistorySheetState extends State<HistorySheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: AppColors.border.withValues(alpha: 0.3),
            ),
          ),
          child: DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.3,
            maxChildSize: 0.9,
            expand: false,
            builder: (context, scrollController) {
              return Column(
                children: [
                  // Drag handle
                  const SizedBox(height: AppSpacing.md),
                  SheetDragHandle(
                    color: AppColors.textMuted.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Header with navigation
                  _buildHeader(context, l10n),
                  const SizedBox(height: AppSpacing.md),

                  // Tab bar
                  _buildTabBar(l10n),
                  const SizedBox(height: AppSpacing.sm),

                  // Tab content
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildHistoryList(context, scrollController, l10n),
                        _buildFavoritesList(context, scrollController, l10n),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Consumer<HistoryProvider>(
      builder: (context, history, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            children: [
              // Title
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.historyTitle,
                      style: AppTypography.headlineMedium,
                    ),
                    if (history.historyCount > 0)
                      Text(
                        l10n.historyPosition(
                          history.currentPosition,
                          history.historyCount,
                        ),
                        style: AppTypography.bodySmall,
                      ),
                  ],
                ),
              ),

              // Navigation buttons
              _NavigationButton(
                icon: Icons.arrow_back_rounded,
                onPressed: history.canGoBack
                    ? () => _navigateBack(context, history)
                    : null,
                tooltip: l10n.historyGoBack,
              ),
              const SizedBox(width: AppSpacing.sm),
              _NavigationButton(
                icon: Icons.arrow_forward_rounded,
                onPressed: history.canGoForward
                    ? () => _navigateForward(context, history)
                    : null,
                tooltip: l10n.historyGoForward,
              ),
              const SizedBox(width: AppSpacing.md),

              // Save as favorite button
              _SaveFavoriteButton(
                isFavorite: history.isCurrentFavorite(),
                onSave: () => _showSaveFavoriteDialog(context, history),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabBar(AppLocalizations l10n) {
    return Consumer<HistoryProvider>(
      builder: (context, history, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: AppTypography.labelLarge,
              dividerHeight: 0,
              padding: const EdgeInsets.all(4),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.history_rounded, size: 18),
                      const SizedBox(width: 6),
                      Text(l10n.historyTabHistory),
                      if (history.historyCount > 0) ...[
                        const SizedBox(width: 4),
                        _CountBadge(count: history.historyCount),
                      ],
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star_rounded, size: 18),
                      const SizedBox(width: 6),
                      Text(l10n.historyTabFavorites),
                      if (history.favoritesCount > 0) ...[
                        const SizedBox(width: 4),
                        _CountBadge(count: history.favoritesCount),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHistoryList(
    BuildContext context,
    ScrollController scrollController,
    AppLocalizations l10n,
  ) {
    return Consumer<HistoryProvider>(
      builder: (context, history, _) {
        if (history.historyCount == 0) {
          return _EmptyState(
            icon: Icons.explore_outlined,
            title: l10n.historyEmptyTitle,
            subtitle: l10n.historyEmptySubtitle,
          );
        }

        // Reverse to show newest first
        final entries = history.history.reversed.toList();
        final currentId = history.currentEntry?.id;

        return ListView.builder(
          controller: scrollController,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index];
            final isCurrent = entry.id == currentId;
            return FadeIn(
              delay: Duration(milliseconds: index * 30),
              child: _HistoryEntryTile(
                entry: entry,
                isCurrent: isCurrent,
                onTap: () => _jumpToEntry(context, history, entry),
                onSaveAsFavorite: () => _showSaveFavoriteDialog(
                  context,
                  history,
                  entry: entry,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFavoritesList(
    BuildContext context,
    ScrollController scrollController,
    AppLocalizations l10n,
  ) {
    return Consumer<HistoryProvider>(
      builder: (context, history, _) {
        if (history.favoritesCount == 0) {
          return _EmptyState(
            icon: Icons.star_outline_rounded,
            title: l10n.favoritesEmptyTitle,
            subtitle: l10n.favoritesEmptySubtitle,
          );
        }

        final favorites = history.favorites.reversed.toList();

        return ListView.builder(
          controller: scrollController,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            final entry = favorites[index];
            return FadeIn(
              delay: Duration(milliseconds: index * 30),
              child: _FavoriteEntryTile(
                entry: entry,
                onTap: () => _applyFavorite(context, history, entry),
                onRename: () => _showRenameFavoriteDialog(context, history, entry),
                onDelete: () => _confirmDeleteFavorite(context, history, entry),
              ),
            );
          },
        );
      },
    );
  }

  void _navigateBack(BuildContext context, HistoryProvider history) {
    final entry = history.goBack();
    if (entry != null) {
      _applyEntry(context, entry);
    }
  }

  void _navigateForward(BuildContext context, HistoryProvider history) {
    final entry = history.goForward();
    if (entry != null) {
      _applyEntry(context, entry);
    }
  }

  void _jumpToEntry(
    BuildContext context,
    HistoryProvider history,
    HistoryEntry entry,
  ) {
    final jumped = history.jumpToEntry(entry.id);
    if (jumped != null) {
      _applyEntry(context, jumped);
    }
  }

  void _applyFavorite(
    BuildContext context,
    HistoryProvider history,
    HistoryEntry entry,
  ) {
    final controller = context.read<FractalController>();
    history.applyToController(entry, controller);
    
    // Record this navigation in history
    history.recordLocation(
      moduleId: entry.moduleId,
      view: entry.view,
      params: entry.params,
    );
  }

  void _applyEntry(BuildContext context, HistoryEntry entry) {
    final controller = context.read<FractalController>();
    final history = context.read<HistoryProvider>();
    history.applyToController(entry, controller);
  }

  void _showSaveFavoriteDialog(
    BuildContext context,
    HistoryProvider history, {
    HistoryEntry? entry,
  }) {
    final l10n = AppLocalizations.of(context)!;
    _nameController.clear();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.saveFavoriteTitle),
        content: TextField(
          controller: _nameController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: l10n.favoritePlaceholder,
            prefixIcon: const Icon(Icons.star_rounded),
          ),
          onSubmitted: (_) => _saveFavorite(dialogContext, history, entry),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.buttonCancel),
          ),
          ElevatedButton(
            onPressed: () => _saveFavorite(dialogContext, history, entry),
            child: Text(l10n.buttonSave),
          ),
        ],
      ),
    );
  }

  void _saveFavorite(
    BuildContext context,
    HistoryProvider history,
    HistoryEntry? entry,
  ) {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    if (entry != null) {
      history.saveAsFavorite(entry, name);
    } else {
      history.saveCurrentAsFavorite(name);
    }

    Navigator.pop(context);
  }

  void _showRenameFavoriteDialog(
    BuildContext context,
    HistoryProvider history,
    HistoryEntry entry,
  ) {
    final l10n = AppLocalizations.of(context)!;
    _nameController.text = entry.name ?? '';

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.renameFavoriteTitle),
        content: TextField(
          controller: _nameController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: l10n.favoritePlaceholder,
            prefixIcon: const Icon(Icons.edit_rounded),
          ),
          onSubmitted: (_) {
            final newName = _nameController.text.trim();
            if (newName.isNotEmpty) {
              history.renameFavorite(entry.id, newName);
            }
            Navigator.pop(dialogContext);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.buttonCancel),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = _nameController.text.trim();
              if (newName.isNotEmpty) {
                history.renameFavorite(entry.id, newName);
              }
              Navigator.pop(dialogContext);
            },
            child: Text(l10n.buttonSave),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteFavorite(
    BuildContext context,
    HistoryProvider history,
    HistoryEntry entry,
  ) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteFavoriteTitle),
        content: Text(l10n.deleteFavoriteMessage(entry.name ?? '')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.buttonCancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            onPressed: () {
              history.removeFavorite(entry.id);
              Navigator.pop(dialogContext);
            },
            child: Text(l10n.buttonDelete),
          ),
        ],
      ),
    );
  }
}

/// Navigation button for back/forward.
class _NavigationButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;

  const _NavigationButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return _SheetIconButton(
      tooltip: tooltip,
      onTap: onPressed,
      backgroundColor: onPressed != null
          ? AppColors.surfaceVariant
          : AppColors.surfaceVariant.withValues(alpha: 0.5),
      icon: icon,
      iconColor: onPressed != null
          ? AppColors.textPrimary
          : AppColors.textMuted.withValues(alpha: 0.5),
    );
  }
}

/// Save as favorite button.
class _SaveFavoriteButton extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onSave;

  const _SaveFavoriteButton({
    required this.isFavorite,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return _SheetIconButton(
      tooltip: isFavorite ? l10n.alreadyFavorite : l10n.saveAsFavorite,
      onTap: isFavorite ? null : onSave,
      backgroundColor: isFavorite
          ? AppColors.primary.withValues(alpha: 0.2)
          : AppColors.surfaceVariant,
      icon: isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
      iconColor: isFavorite ? AppColors.primary : AppColors.textSecondary,
    );
  }
}

/// Shared 40×40 rounded icon button shell used by the history header buttons.
///
/// The chrome (tooltip, Material + InkWell with radius 10, centered 20px icon)
/// is identical across buttons; callers supply the colors, icon, tooltip, and
/// tap handler.
class _SheetIconButton extends StatelessWidget {
  final String tooltip;
  final Color backgroundColor;
  final VoidCallback? onTap;
  final IconData icon;
  final Color iconColor;

  const _SheetIconButton({
    required this.tooltip,
    required this.backgroundColor,
    required this.onTap,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            child: Icon(icon, size: 20, color: iconColor),
          ),
        ),
      ),
    );
  }
}

/// Small count badge.
class _CountBadge extends StatelessWidget {
  final int count;

  const _CountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        count.toString(),
        style: AppTypography.labelSmall.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Empty state placeholder.
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 64,
              color: AppColors.textMuted.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: AppTypography.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              subtitle,
              style: AppTypography.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// History entry list tile.
class _HistoryEntryTile extends StatelessWidget {
  final HistoryEntry entry;
  final bool isCurrent;
  final VoidCallback onTap;
  final VoidCallback onSaveAsFavorite;

  const _HistoryEntryTile({
    required this.entry,
    required this.isCurrent,
    required this.onTap,
    required this.onSaveAsFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat.Hm();
    final dateFormat = DateFormat.MMMd();

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: isCurrent
            ? AppColors.primary.withValues(alpha: 0.15)
            : AppColors.surfaceVariant.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: isCurrent
            ? Border.all(color: AppColors.primary.withValues(alpha: 0.5))
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                // Module icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? AppColors.primary.withValues(alpha: 0.2)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getModuleIcon(entry.moduleId),
                    size: 20,
                    color: isCurrent ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.displayLabel,
                        style: AppTypography.titleMedium.copyWith(
                          color: isCurrent
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${dateFormat.format(entry.visitedAt)} ${timeFormat.format(entry.visitedAt)}',
                        style: AppTypography.bodySmall,
                      ),
                    ],
                  ),
                ),

                // Current indicator or save button
                if (isCurrent)
                  Builder(
                    builder: (context) {
                      final l10n = AppLocalizations.of(context)!;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          l10n.historyCurrentLocation,
                          style: AppTypography.labelSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    },
                  )
                else
                  Builder(
                    builder: (context) {
                      final l10n = AppLocalizations.of(context)!;
                      return IconButton(
                        icon: const Icon(Icons.star_outline_rounded, size: 20),
                        color: AppColors.textMuted,
                        onPressed: onSaveAsFavorite,
                        tooltip: l10n.historySaveAsFavorite,
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getModuleIcon(String moduleId) {
    switch (moduleId) {
      case 'mandelbrot':
        return Icons.blur_circular_rounded;
      case 'julia':
        return Icons.auto_awesome;
      case 'mandelbulb':
        return Icons.view_in_ar_rounded;
      case 'burning_ship':
        return Icons.local_fire_department_rounded;
      case 'phoenix':
        return Icons.whatshot_rounded;
      default:
        return Icons.grain_rounded;
    }
  }
}

/// Favorite entry list tile.
class _FavoriteEntryTile extends StatelessWidget {
  final HistoryEntry entry;
  final VoidCallback onTap;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  const _FavoriteEntryTile({
    required this.entry,
    required this.onTap,
    required this.onRename,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat.yMMMd();

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                // Star icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.star_rounded,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Builder(
                        builder: (context) {
                          final l10n = AppLocalizations.of(context)!;
                          return Text(
                            entry.name ?? l10n.historyUnnamed,
                            style: AppTypography.titleMedium,
                          );
                        },
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${entry.moduleId} • ${dateFormat.format(entry.visitedAt)}',
                        style: AppTypography.bodySmall,
                      ),
                    ],
                  ),
                ),

                // Actions
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert_rounded,
                    size: 20,
                    color: AppColors.textMuted,
                  ),
                  itemBuilder: (context) {
                    final l10n = AppLocalizations.of(context)!;
                    return [
                      PopupMenuItem(
                        value: 'rename',
                        child: Row(
                          children: [
                            const Icon(Icons.edit_rounded, size: 18),
                            const SizedBox(width: 8),
                            Text(l10n.historyRename),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(Icons.delete_rounded, size: 18, color: AppColors.error),
                            const SizedBox(width: 8),
                            Text(l10n.historyDelete, style: const TextStyle(color: AppColors.error)),
                          ],
                        ),
                      ),
                    ];
                  },
                  onSelected: (value) {
                    if (value == 'rename') {
                      onRename();
                    } else if (value == 'delete') {
                      onDelete();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

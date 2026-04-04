import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_fractals/core/services/app_logger_service.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/features/debug/log_share_service.dart';
import 'package:flutter_fractals/features/debug/log_viewer_state.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';

/// Full-screen log viewer with export capability.
class LogViewerScreen extends StatefulWidget {
  final AppLogger logger;
  final LogShareService shareService;

  LogViewerScreen({
    super.key,
    AppLogger? logger,
    this.shareService = const SharePlusLogShareService(),
  }) : logger = logger ?? AppLogger.instance;

  @override
  State<LogViewerScreen> createState() => _LogViewerScreenState();
}

class _LogViewerScreenState extends State<LogViewerScreen> {
  final ScrollController _scroll = ScrollController();
  LogLevel? _filter;

  @override
  void initState() {
    super.initState();
    widget.logger.addListener(_onLogChanged);
  }

  @override
  void dispose() {
    widget.logger.removeListener(_onLogChanged);
    _scroll.dispose();
    super.dispose();
  }

  void _onLogChanged() {
    if (!mounted) {
      return;
    }

    setState(() {});
    _scheduleAutoScroll();
  }

  void _scheduleAutoScroll() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) {
        return;
      }

      final position = _scroll.position;
      if (!position.hasPixels) {
        return;
      }

      try {
        _scroll.jumpTo(position.maxScrollExtent);
      } catch (_) {
        // The logger can update while the list is still attaching. Missing one
        // auto-scroll event is acceptable; crashing the screen is not.
      }
    });
  }

  LogViewerState get _state {
    return LogViewerStateFactory.build(
      entries: widget.logger.entries,
      filter: _filter,
    );
  }

  Future<void> _exportLog() async {
    final l10n = AppLocalizations.of(context)!;
    final exportData = LogViewerStateFactory.buildExportData(
      text: widget.logger.exportText(minLevel: _filter),
      json: widget.logger.exportJson(minLevel: _filter),
      timestamp: DateTime.now(),
    );

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => SafeArea(
        child: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.logExportTitle(widget.logger.length),
                  style: AppTypography.titleMedium),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _ExportButton(
                      icon: Icons.copy_rounded,
                      label: l10n.logCopyText,
                      onTap: () {
                        _copyToClipboard(
                          sheetContext: sheetContext,
                          content: exportData.text,
                          confirmationMessage: l10n.logCopied,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ExportButton(
                      icon: Icons.share_rounded,
                      label: l10n.logShareText,
                      onTap: () async {
                        await _shareText(
                          sheetContext: sheetContext,
                          content: exportData.text,
                          filename: exportData.textFilename,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ExportButton(
                      icon: Icons.data_object_rounded,
                      label: l10n.logShareJson,
                      onTap: () async {
                        await _shareText(
                          sheetContext: sheetContext,
                          content: exportData.json,
                          filename: exportData.jsonFilename,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _copyToClipboard({
    required BuildContext sheetContext,
    required String content,
    required String confirmationMessage,
  }) {
    Clipboard.setData(ClipboardData(text: content));
    Navigator.of(sheetContext).pop();
    _showSnackBar(confirmationMessage);
  }

  Future<void> _shareText({
    required BuildContext sheetContext,
    required String content,
    required String filename,
  }) async {
    Navigator.of(sheetContext).pop();

    try {
      await widget.shareService.shareText(
        content: content,
        filename: filename,
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      _showSnackBar(AppLocalizations.of(context)!.logShareFailed(e.toString()));
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  List<LogFilterOption> _buildFilterOptions(AppLocalizations l10n) {
    return [
      LogFilterOption(level: null, label: l10n.logFilterAll),
      LogFilterOption(level: LogLevel.debug, label: l10n.logFilterDebug),
      LogFilterOption(level: LogLevel.info, label: l10n.logFilterInfo),
      LogFilterOption(level: LogLevel.warn, label: l10n.logFilterWarn),
      LogFilterOption(level: LogLevel.error, label: l10n.logFilterError),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = _state;
    final filterOptions = _buildFilterOptions(l10n);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(l10n.logViewerTitle(state.visibleCount, state.totalCount)),
        backgroundColor: Colors.black,
        actions: [
          PopupMenuButton<LogLevel?>(
            key: const ValueKey('logFilterButton'),
            icon: Icon(
              Icons.filter_list_rounded,
              color: _filter != null ? Colors.amber : Colors.white,
            ),
            tooltip: l10n.logFilterTooltip,
            onSelected: (v) => setState(() => _filter = v),
            itemBuilder: (_) => filterOptions
                .map(
                  (option) => PopupMenuItem<LogLevel?>(
                    value: option.level,
                    child: Text(option.label),
                  ),
                )
                .toList(growable: false),
          ),
          IconButton(
            key: const ValueKey('logExportButton'),
            icon: const Icon(Icons.file_upload_outlined),
            tooltip: l10n.logTooltipExport,
            onPressed: _exportLog,
          ),
          IconButton(
            key: const ValueKey('logClearButton'),
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: l10n.logTooltipClear,
            onPressed: widget.logger.clear,
          ),
        ],
      ),
      body: state.isEmpty
          ? Center(
              child: Text(l10n.logNoEntries,
                  style: const TextStyle(color: Colors.white38)))
          : ListView.builder(
              controller: _scroll,
              itemCount: state.visibleEntries.length,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              itemBuilder: (context, index) {
                final entry = state.visibleEntries[index];
                return _LogTile(
                  entry: entry,
                  color: LogViewerStateFactory.colorForLevel(entry.level),
                );
              },
            ),
    );
  }
}

class _LogTile extends StatelessWidget {
  const _LogTile({required this.entry, required this.color});

  final LogEntry entry;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final ts =
        '${entry.timestamp.hour.toString().padLeft(2, '0')}:${entry.timestamp.minute.toString().padLeft(2, '0')}:${entry.timestamp.second.toString().padLeft(2, '0')}.${entry.timestamp.millisecond.toString().padLeft(3, '0')}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ts,
            style: const TextStyle(
                color: Colors.white38, fontFamily: 'monospace', fontSize: 10),
          ),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              entry.category,
              style: TextStyle(
                  color: color.withValues(alpha: 0.8),
                  fontFamily: 'monospace',
                  fontSize: 10,
                  fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              entry.data != null
                  ? '${entry.message} ${entry.data}'
                  : entry.message,
              style: TextStyle(
                  color: color, fontFamily: 'monospace', fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExportButton extends StatelessWidget {
  const _ExportButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            children: [
              Icon(icon, color: AppColors.primary, size: 24),
              const SizedBox(height: 4),
              Text(label,
                  style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

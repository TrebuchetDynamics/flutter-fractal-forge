import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_fractals/core/services/diagnostics/app_logger_service.dart';
import 'package:flutter_fractals/core/services/export/export_service.dart';
import 'package:flutter_fractals/core/services/export/share_service.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';

/// Full-screen log viewer with export capability.
class LogViewerScreen extends StatefulWidget {
  const LogViewerScreen({super.key});

  @override
  State<LogViewerScreen> createState() => _LogViewerScreenState();
}

class _LogViewerScreenState extends State<LogViewerScreen> {
  final AppLogger _log = AppLogger.instance;
  final ScrollController _scroll = ScrollController();
  LogLevel? _filter;
  final bool _autoScroll = true;

  @override
  void initState() {
    super.initState();
    _log.addListener(_onLogChanged);
  }

  @override
  void dispose() {
    _log.removeListener(_onLogChanged);
    _scroll.dispose();
    super.dispose();
  }

  void _onLogChanged() {
    if (mounted) {
      setState(() {});
      if (_autoScroll) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scroll.hasClients) {
            _scroll.jumpTo(_scroll.position.maxScrollExtent);
          }
        });
      }
    }
  }

  List<LogEntry> get _filtered {
    if (_filter == null) return _log.entries;
    return _log.entries.where((e) => e.level.index >= _filter!.index).toList();
  }

  Color _colorForLevel(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return Colors.grey;
      case LogLevel.info:
        return Colors.white;
      case LogLevel.warn:
        return Colors.amber;
      case LogLevel.error:
        return Colors.redAccent;
    }
  }

  Future<void> _exportLog() async {
    final l10n = AppLocalizations.of(context)!;
    final text = _log.exportText(minLevel: _filter);
    final json = _log.exportJson(minLevel: _filter);

    final ts = DateTime.now().millisecondsSinceEpoch;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SafeArea(
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
              Text(l10n.logExportTitle(_log.length),
                  style: AppTypography.titleMedium),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _ExportButton(
                      icon: Icons.copy_rounded,
                      label: l10n.logCopyText,
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: text));
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.logCopied)),
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
                        Navigator.pop(ctx);
                        await _shareText(text, 'fractal_log_$ts.txt');
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ExportButton(
                      icon: Icons.data_object_rounded,
                      label: l10n.logShareJson,
                      onTap: () async {
                        Navigator.pop(ctx);
                        await _shareText(json, 'fractal_log_$ts.json');
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

  Future<void> _shareText(String content, String filename) async {
    try {
      const exportService = ExportService();
      final file = await exportService.saveBytes(
        Uint8List.fromList(content.codeUnits),
        filename: filename,
      );
      await const AppShareService().shareFile(
        file,
        text: 'Flutter Fractal Forge diagnostic log',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                AppLocalizations.of(context)!.logShareFailed(e.toString()))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final entries = _filtered;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(l10n.logViewerTitle(entries.length, _log.length)),
        backgroundColor: Colors.black,
        actions: [
          // Filter chips
          PopupMenuButton<LogLevel?>(
            icon: Icon(
              Icons.filter_list_rounded,
              color: _filter != null ? Colors.amber : Colors.white,
            ),
            tooltip: l10n.logFilterTooltip,
            onSelected: (v) => setState(() => _filter = v),
            itemBuilder: (_) => [
              PopupMenuItem(value: null, child: Text(l10n.logFilterAll)),
              PopupMenuItem(
                  value: LogLevel.debug, child: Text(l10n.logFilterDebug)),
              PopupMenuItem(
                  value: LogLevel.info, child: Text(l10n.logFilterInfo)),
              PopupMenuItem(
                  value: LogLevel.warn, child: Text(l10n.logFilterWarn)),
              PopupMenuItem(
                  value: LogLevel.error, child: Text(l10n.logFilterError)),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.file_upload_outlined),
            tooltip: l10n.logTooltipExport,
            onPressed: _exportLog,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: l10n.logTooltipClear,
            onPressed: () {
              _log.clear();
              setState(() {});
            },
          ),
        ],
      ),
      body: entries.isEmpty
          ? Center(
              child: Text(l10n.logNoEntries,
                  style: const TextStyle(color: Colors.white38)))
          : ListView.builder(
              controller: _scroll,
              itemCount: entries.length,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              itemBuilder: (context, index) {
                final e = entries[index];
                return _LogTile(entry: e, color: _colorForLevel(e.level));
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

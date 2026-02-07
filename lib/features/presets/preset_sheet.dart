import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_fractals/core/models/fractal_preset.dart';
import 'package:flutter_fractals/core/services/preset_store.dart';
import 'package:flutter_fractals/features/renderer/providers/fractal_provider.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';

class PresetSheet extends StatefulWidget {
  const PresetSheet({Key? key}) : super(key: key);

  @override
  State<PresetSheet> createState() => _PresetSheetState();
}

class _PresetSheetState extends State<PresetSheet> {
  final TextEditingController _nameController = TextEditingController();
  bool _saving = false;
  Future<List<FractalPreset>>? _userPresetsFuture;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() {
      // So the Save button can enable/disable as the user types.
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<FractalController>();
    final presetStore = context.read<PresetStore>();
    final l10n = AppLocalizations.of(context)!;

    _userPresetsFuture ??= presetStore.loadUserPresets(controller.module.id);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.presetsTitle, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Text(l10n.savePreset, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: l10n.presetNameHint,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  key: const Key('savePresetButton'),
                  onPressed: (_saving || _nameController.text.trim().isEmpty)
                      ? null
                      : () async {
                          final name = _nameController.text.trim();
                          if (name.isEmpty) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(l10n.presetNameRequired)),
                              );
                            }
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
                                SnackBar(content: Text(l10n.presetSaved)),
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
                        },
                  child: _saving
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        )
                      : Text(l10n.savePreset),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(l10n.builtInPresets, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: controller.module.builtInPresets.map((preset) {
                return ActionChip(
                  label: Text(_presetName(context, preset)),
                  onPressed: () {
                    controller.applyPreset(preset);
                    Navigator.of(context).pop();
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Text(l10n.userPresets, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            FutureBuilder<List<FractalPreset>>(
              future: _userPresetsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        const SizedBox(width: 12),
                        Text(l10n.loadingPresets),
                      ],
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.presetsLoadFailed),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _userPresetsFuture = presetStore.loadUserPresets(controller.module.id);
                            });
                          },
                          child: Text(l10n.actionRetry),
                        ),
                      ],
                    ),
                  );
                }
                final presets = snapshot.data ?? [];
                if (presets.isEmpty) {
                  return Text(
                    l10n.noUserPresets,
                    style: Theme.of(context).textTheme.bodyMedium,
                  );
                }
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: presets.map((preset) {
                    return ActionChip(
                      label: Text(preset.name),
                      onPressed: () {
                        controller.applyPreset(preset);
                        Navigator.of(context).pop();
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
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

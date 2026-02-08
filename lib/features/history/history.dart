/// Exploration history feature for tracking and revisiting fractal locations.
///
/// This library exports all components needed to use the history feature:
/// - [HistoryEntry]: Model for a visited location
/// - [HistoryProvider]: State management for history and favorites
/// - [HistorySheet]: UI for browsing and managing history
///
/// Usage:
/// ```dart
/// // In main.dart, add HistoryStore and HistoryProvider to providers
/// final historyStore = await HistoryStore.create();
/// ChangeNotifierProvider<HistoryProvider>(
///   create: (_) => HistoryProvider(store: historyStore),
/// ),
///
/// // Record navigation
/// final history = context.read<HistoryProvider>();
/// history.recordLocation(
///   moduleId: controller.module.id,
///   view: controller.view,
///   params: controller.params,
/// );
///
/// // Go back/forward
/// if (history.canGoBack) {
///   final entry = history.goBack();
///   history.applyToController(entry!, controller);
/// }
///
/// // Save favorite
/// await history.saveCurrentAsFavorite('Deep Spiral');
/// ```
library;

export 'history_entry.dart';
export 'history_provider.dart';
export 'history_sheet.dart';

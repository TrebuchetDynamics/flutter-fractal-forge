import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/services/diagnostics/crash_reporter.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';

/// Callback type for error events within an [ErrorBoundary].
typedef ErrorCallback = void Function(Object error, StackTrace? stack);

/// The severity level of an error for display and handling purposes.
enum ErrorSeverity {
  /// Low-impact error that doesn't prevent core functionality.
  warning,

  /// Standard error that affects the current feature.
  error,

  /// Critical error that may affect the entire application.
  critical,
}

/// Configuration for an [ErrorBoundary] widget.
class ErrorBoundaryConfig {
  /// The title shown in the error display.
  final String? title;

  /// The message shown in the error display.
  final String? message;

  /// Whether to show a retry button.
  final bool showRetry;

  /// Whether to show the technical error details.
  final bool showDetails;

  /// The severity level for this boundary.
  final ErrorSeverity severity;

  /// Custom icon to display.
  final IconData? icon;

  /// Custom action buttons to show.
  final List<ErrorAction>? actions;

  const ErrorBoundaryConfig({
    this.title,
    this.message,
    this.showRetry = true,
    this.showDetails = true,
    this.severity = ErrorSeverity.error,
    this.icon,
    this.actions,
  });

  /// Default configuration for shader-related errors.
  static const shader = ErrorBoundaryConfig(
    title: 'Shader Error',
    message: 'Failed to compile or load the shader. Try a different fractal or restart the app.',
    showRetry: true,
    showDetails: true,
    severity: ErrorSeverity.error,
    icon: Icons.memory_rounded,
  );

  /// Default configuration for network errors.
  static const network = ErrorBoundaryConfig(
    title: 'Connection Error',
    message: 'Unable to connect. Check your internet connection.',
    showRetry: true,
    showDetails: false,
    severity: ErrorSeverity.warning,
    icon: Icons.wifi_off_rounded,
  );

  /// Default configuration for critical errors.
  static const critical = ErrorBoundaryConfig(
    title: 'Something Went Wrong',
    message: 'An unexpected error occurred. Please restart the app.',
    showRetry: false,
    showDetails: true,
    severity: ErrorSeverity.critical,
    icon: Icons.error_outline_rounded,
  );
}

/// A custom action button for the error display.
class ErrorAction {
  /// The button label.
  final String label;

  /// The icon to show (optional).
  final IconData? icon;

  /// Whether this is the primary action.
  final bool isPrimary;

  /// The callback when pressed.
  final VoidCallback onPressed;

  const ErrorAction({
    required this.label,
    required this.onPressed,
    this.icon,
    this.isPrimary = false,
  });
}

/// A widget that catches errors in its child widget tree and displays
/// a fallback UI with recovery options.
///
/// [ErrorBoundary] wraps widgets that may throw errors and provides:
/// - Graceful error display with configurable appearance
/// - Automatic crash reporting to [CrashReporter]
/// - Retry functionality for recoverable errors
/// - Custom fallback widgets for different error types
///
/// ## Usage
///
/// Wrap potentially failing widgets:
/// ```dart
/// ErrorBoundary(
///   config: ErrorBoundaryConfig.shader,
///   onError: (error, stack) => analytics.logError(error),
///   child: FractalRenderer(...),
/// )
/// ```
///
/// With custom fallback:
/// ```dart
/// ErrorBoundary(
///   fallbackBuilder: (context, error, retry) => CustomErrorWidget(
///     error: error,
///     onRetry: retry,
///   ),
///   child: SomeWidget(),
/// )
/// ```
///
/// {@category Error Handling}
class ErrorBoundary extends StatefulWidget {
  /// The child widget to wrap with error protection.
  final Widget child;

  /// Configuration for the error display.
  final ErrorBoundaryConfig config;

  /// Called when an error is caught.
  final ErrorCallback? onError;

  /// Custom builder for the fallback UI.
  ///
  /// If provided, overrides the default error display.
  final Widget Function(BuildContext, Object, VoidCallback)? fallbackBuilder;

  /// Optional key for testing the retry functionality.
  final Key? retryButtonKey;

  const ErrorBoundary({
    Key? key,
    required this.child,
    this.config = const ErrorBoundaryConfig(),
    this.onError,
    this.fallbackBuilder,
    this.retryButtonKey,
  }) : super(key: key);

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;
  bool _showDetails = false;

  @override
  void initState() {
    super.initState();
  }

  void _handleError(Object error, StackTrace? stack) {
    // Report to crash reporter
    CrashReporter.instance.record(
      error,
      stack,
      source: 'error_boundary',
      fatal: widget.config.severity == ErrorSeverity.critical,
    );

    // Notify callback
    widget.onError?.call(error, stack);

    if (mounted) {
      setState(() {
        _error = error;
        _stackTrace = stack;
      });
    }
  }

  void _retry() {
    setState(() {
      _error = null;
      _stackTrace = null;
      _showDetails = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      if (widget.fallbackBuilder != null) {
        return widget.fallbackBuilder!(context, _error!, _retry);
      }
      return _DefaultErrorDisplay(
        error: _error!,
        stackTrace: _stackTrace,
        config: widget.config,
        showDetails: _showDetails,
        onToggleDetails: () => setState(() => _showDetails = !_showDetails),
        onRetry: _retry,
        retryButtonKey: widget.retryButtonKey,
      );
    }

    return _ErrorBoundaryWrapper(
      onError: _handleError,
      child: widget.child,
    );
  }
}

/// Internal wrapper that catches errors in the widget tree.
///
/// This uses ErrorWidget.builder to catch build-time errors.
class _ErrorBoundaryWrapper extends StatefulWidget {
  final Widget child;
  final void Function(Object, StackTrace?) onError;

  const _ErrorBoundaryWrapper({
    required this.child,
    required this.onError,
  });

  @override
  State<_ErrorBoundaryWrapper> createState() => _ErrorBoundaryWrapperState();
}

class _ErrorBoundaryWrapperState extends State<_ErrorBoundaryWrapper> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Default error display widget with Material Design styling.
class _DefaultErrorDisplay extends StatelessWidget {
  final Object error;
  final StackTrace? stackTrace;
  final ErrorBoundaryConfig config;
  final bool showDetails;
  final VoidCallback onToggleDetails;
  final VoidCallback onRetry;
  final Key? retryButtonKey;

  const _DefaultErrorDisplay({
    required this.error,
    required this.stackTrace,
    required this.config,
    required this.showDetails,
    required this.onToggleDetails,
    required this.onRetry,
    this.retryButtonKey,
  });

  Color get _severityColor {
    switch (config.severity) {
      case ErrorSeverity.warning:
        return AppColors.warning;
      case ErrorSeverity.error:
        return AppColors.error;
      case ErrorSeverity.critical:
        return AppColors.error;
    }
  }

  IconData get _icon {
    return config.icon ?? Icons.error_outline_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final title = config.title ?? 'An Error Occurred';
    final message = config.message ?? 'Something went wrong. Please try again.';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Error icon with severity color
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: _severityColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: _severityColor.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                _icon,
                size: 48,
                color: _severityColor,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Title
            Text(
              title,
              style: AppTypography.titleLarge.copyWith(
                color: _severityColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),

            // Message
            Text(
              message,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),

            // Action buttons
            _buildActions(context),

            // Expandable details section
            if (config.showDetails) ...[
              const SizedBox(height: AppSpacing.lg),
              _buildDetailsSection(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    final actions = config.actions ?? [];

    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.sm,
      alignment: WrapAlignment.center,
      children: [
        // Custom actions
        for (final action in actions)
          action.isPrimary
              ? ElevatedButton.icon(
                  onPressed: action.onPressed,
                  icon: action.icon != null ? Icon(action.icon, size: 18) : const SizedBox.shrink(),
                  label: Text(action.label),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                )
              : OutlinedButton.icon(
                  onPressed: action.onPressed,
                  icon: action.icon != null ? Icon(action.icon, size: 18) : const SizedBox.shrink(),
                  label: Text(action.label),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

        // Default retry button
        if (config.showRetry)
          ElevatedButton.icon(
            key: retryButtonKey,
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDetailsSection(BuildContext context) {
    return Column(
      children: [
        // Toggle button
        TextButton.icon(
          onPressed: onToggleDetails,
          icon: Icon(
            showDetails ? Icons.expand_less_rounded : Icons.expand_more_rounded,
            size: 18,
          ),
          label: Text(showDetails ? 'Hide Details' : 'Show Details'),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textMuted,
          ),
        ),

        // Details panel
        AnimatedCrossFade(
          duration: AppAnimations.fast,
          crossFadeState: showDetails ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          firstChild: const SizedBox.shrink(),
          secondChild: Container(
            margin: const EdgeInsets.only(top: AppSpacing.sm),
            padding: const EdgeInsets.all(AppSpacing.md),
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border.withValues(alpha: 0.3)),
            ),
            constraints: const BoxConstraints(maxHeight: 200),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Error type
                  Text(
                    error.runtimeType.toString(),
                    style: AppTypography.labelMedium.copyWith(
                      color: _severityColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),

                  // Error message
                  SelectableText(
                    error.toString(),
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontFamily: 'monospace',
                    ),
                  ),

                  // Stack trace (truncated)
                  if (stackTrace != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    const Divider(height: 1),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Stack Trace',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    SelectableText(
                      _truncateStackTrace(stackTrace!),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textMuted,
                        fontFamily: 'monospace',
                        fontSize: 10,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _truncateStackTrace(StackTrace stack) {
    final lines = stack.toString().split('\n');
    final truncated = lines.take(10).join('\n');
    if (lines.length > 10) {
      return '$truncated\n... and ${lines.length - 10} more lines';
    }
    return truncated;
  }
}

/// A specialized error boundary for shader-related operations.
///
/// Provides additional recovery options specific to shader failures,
/// such as switching to a fallback renderer or clearing shader cache.
///
/// {@category Error Handling}
class ShaderErrorBoundary extends StatefulWidget {
  /// The child widget to protect.
  final Widget child;

  /// Called when a shader error occurs.
  final ErrorCallback? onShaderError;

  /// Called when the user requests to switch fractals.
  final VoidCallback? onSwitchFractal;

  /// Custom fallback widget.
  final Widget? fallback;

  /// Maximum retry attempts before showing permanent error.
  final int maxRetries;

  const ShaderErrorBoundary({
    Key? key,
    required this.child,
    this.onShaderError,
    this.onSwitchFractal,
    this.fallback,
    this.maxRetries = 3,
  }) : super(key: key);

  @override
  State<ShaderErrorBoundary> createState() => _ShaderErrorBoundaryState();
}

class _ShaderErrorBoundaryState extends State<ShaderErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;
  int _retryCount = 0;
  bool _permanentFailure = false;

  void _handleError(Object error, StackTrace? stack) {
    // Check if it's a shader-specific error
    final isShaderError = error.toString().toLowerCase().contains('shader') ||
        error.toString().toLowerCase().contains('fragment') ||
        error.toString().toLowerCase().contains('compile');

    CrashReporter.instance.record(
      error,
      stack,
      source: isShaderError ? 'shader_error_boundary' : 'error_boundary',
      fatal: false,
    );

    widget.onShaderError?.call(error, stack);

    if (mounted) {
      setState(() {
        _error = error;
        _stackTrace = stack;
        _retryCount++;
        _permanentFailure = _retryCount >= widget.maxRetries;
      });
    }
  }

  void _retry() {
    if (_permanentFailure) return;

    setState(() {
      _error = null;
      _stackTrace = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      if (widget.fallback != null) {
        return widget.fallback!;
      }
      return _ShaderErrorDisplay(
        error: _error!,
        stackTrace: _stackTrace,
        retryCount: _retryCount,
        maxRetries: widget.maxRetries,
        permanentFailure: _permanentFailure,
        onRetry: _retry,
        onSwitchFractal: widget.onSwitchFractal,
      );
    }

    return ErrorBoundary(
      config: ErrorBoundaryConfig.shader,
      onError: _handleError,
      fallbackBuilder: (context, error, retry) {
        _handleError(error, null);
        return const SizedBox.shrink();
      },
      child: widget.child,
    );
  }
}

class _ShaderErrorDisplay extends StatelessWidget {
  final Object error;
  final StackTrace? stackTrace;
  final int retryCount;
  final int maxRetries;
  final bool permanentFailure;
  final VoidCallback onRetry;
  final VoidCallback? onSwitchFractal;

  const _ShaderErrorDisplay({
    required this.error,
    required this.stackTrace,
    required this.retryCount,
    required this.maxRetries,
    required this.permanentFailure,
    required this.onRetry,
    this.onSwitchFractal,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated shader icon
            TweenAnimationBuilder<double>(
              duration: const Duration(seconds: 2),
              tween: Tween(begin: 0, end: 1),
              builder: (context, value, child) {
                return Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.error.withValues(alpha: 0.1),
                        AppColors.warning.withValues(alpha: 0.1),
                      ],
                      transform: GradientRotation(value * 6.28),
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.memory_rounded,
                    size: 48,
                    color: AppColors.error,
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),

            Text(
              permanentFailure ? 'Shader Failed to Load' : 'Shader Error',
              style: AppTypography.titleLarge.copyWith(
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            Text(
              permanentFailure
                  ? 'This fractal is not compatible with your device. Try a different fractal.'
                  : 'Failed to compile the shader. Attempt $retryCount of $maxRetries.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),

            // Actions
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.sm,
              alignment: WrapAlignment.center,
              children: [
                if (!permanentFailure)
                  ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                if (onSwitchFractal != null)
                  OutlinedButton.icon(
                    onPressed: onSwitchFractal,
                    icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                    label: const Text('Switch Fractal'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),

            // Error details
            const SizedBox(height: AppSpacing.xl),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                error.toString().length > 200
                    ? '${error.toString().substring(0, 200)}...'
                    : error.toString(),
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textMuted,
                  fontFamily: 'monospace',
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Extension to easily wrap widgets with error boundaries.
extension ErrorBoundaryExtension on Widget {
  /// Wraps this widget with an [ErrorBoundary].
  Widget withErrorBoundary({
    ErrorBoundaryConfig config = const ErrorBoundaryConfig(),
    ErrorCallback? onError,
  }) {
    return ErrorBoundary(
      config: config,
      onError: onError,
      child: this,
    );
  }

  /// Wraps this widget with a [ShaderErrorBoundary].
  Widget withShaderErrorBoundary({
    ErrorCallback? onShaderError,
    VoidCallback? onSwitchFractal,
    int maxRetries = 3,
  }) {
    return ShaderErrorBoundary(
      onShaderError: onShaderError,
      onSwitchFractal: onSwitchFractal,
      maxRetries: maxRetries,
      child: this,
    );
  }
}

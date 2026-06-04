part of '../fractal_renderer.dart';

/// Displays shader loading errors with recovery options.
class _ShaderErrorDisplay extends StatefulWidget {
  final String errorMessage;
  final String? errorDetails;
  final ShaderErrorType errorType;
  final int retryCount;
  final int maxRetries;
  final VoidCallback onRetry;
  final VoidCallback onGoBack;

  const _ShaderErrorDisplay({
    required this.errorMessage,
    this.errorDetails,
    required this.errorType,
    required this.retryCount,
    required this.maxRetries,
    required this.onRetry,
    required this.onGoBack,
  });

  @override
  State<_ShaderErrorDisplay> createState() => _ShaderErrorDisplayState();
}

class _ShaderErrorDisplayState extends State<_ShaderErrorDisplay>
    with SingleTickerProviderStateMixin {
  static const ShaderErrorPolicy _shaderErrorPolicy = ShaderErrorPolicy();

  bool _showDetails = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  IconData get _errorIcon {
    switch (widget.errorType) {
      case ShaderErrorType.compilation:
        return Icons.code_off_rounded;
      case ShaderErrorType.assetNotFound:
        return Icons.folder_off_rounded;
      case ShaderErrorType.outOfMemory:
        return Icons.memory_rounded;
      case ShaderErrorType.gpuUnsupported:
        return Icons.desktop_access_disabled_rounded;
      case ShaderErrorType.unknown:
        return Icons.error_outline_rounded;
    }
  }

  Color get _errorColor {
    switch (widget.errorType) {
      case ShaderErrorType.compilation:
      case ShaderErrorType.unknown:
        return AppColors.error;
      case ShaderErrorType.assetNotFound:
        return AppColors.warning;
      case ShaderErrorType.outOfMemory:
      case ShaderErrorType.gpuUnsupported:
        return AppColors.error;
    }
  }

  bool get _canRetry => widget.retryCount < widget.maxRetries;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated error icon
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  final pulse = 1.0 + (_pulseController.value * 0.1);
                  return Transform.scale(
                    scale: pulse,
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: _errorColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _errorColor.withValues(alpha: 0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _errorColor.withValues(
                                alpha: 0.2 * _pulseController.value),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        _errorIcon,
                        size: 48,
                        color: _errorColor,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.xl),

              // Error title
              Text(
                'Shader Error',
                style: AppTypography.titleLarge.copyWith(
                  color: _errorColor,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // Retry count indicator
              if (widget.retryCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Attempt ${widget.retryCount}/${widget.maxRetries}',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              const SizedBox(height: AppSpacing.md),

              // Error message
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.border.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  widget.errorMessage,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Action buttons
              Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.sm,
                alignment: WrapAlignment.center,
                children: [
                  if (_canRetry)
                    ElevatedButton.icon(
                      onPressed: widget.onRetry,
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: Text(
                          AppLocalizations.of(context)!.shaderErrorTryAgain),
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
                  OutlinedButton.icon(
                    onPressed: widget.onGoBack,
                    icon: const Icon(Icons.arrow_back_rounded, size: 18),
                    label:
                        Text(AppLocalizations.of(context)!.shaderErrorGoBack),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: BorderSide(
                        color: AppColors.border.withValues(alpha: 0.5),
                      ),
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
              ),

              // Technical details section
              if (widget.errorDetails != null) ...[
                const SizedBox(height: AppSpacing.xl),
                TextButton.icon(
                  onPressed: () => setState(() => _showDetails = !_showDetails),
                  icon: Icon(
                    _showDetails
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    size: 18,
                  ),
                  label: Text(_showDetails ? 'Hide Details' : 'Show Details'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textMuted,
                  ),
                ),
                AnimatedCrossFade(
                  duration: AppAnimations.fast,
                  crossFadeState: _showDetails
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  firstChild: const SizedBox.shrink(),
                  secondChild: Container(
                    margin: const EdgeInsets.only(top: AppSpacing.sm),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.border.withValues(alpha: 0.2),
                      ),
                    ),
                    child: SelectableText(
                      widget.errorDetails!,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textMuted,
                        fontFamily: 'monospace',
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              ],

              // Helpful tips
              const SizedBox(height: AppSpacing.xl),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline_rounded,
                      color: AppColors.primary.withValues(alpha: 0.7),
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        _getTipForErrorType(),
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTipForErrorType() => _shaderErrorPolicy.tipFor(widget.errorType);
}

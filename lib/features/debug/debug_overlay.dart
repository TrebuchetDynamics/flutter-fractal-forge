import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/services/debug_runner_service.dart';

class DebugOverlay extends StatelessWidget {
  final DebugRunnerService runner;
  final GlobalKey boundaryKey;

  const DebugOverlay({
    Key? key,
    required this.runner,
    required this.boundaryKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const SizedBox.shrink();

    return ListenableBuilder(
      listenable: runner,
      builder: (context, _) {
        switch (runner.state) {
          case DebugRunState.idle:
            return Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                heroTag: 'debugFab',
                onPressed: () => runner.run(boundaryKey),
                backgroundColor: Colors.deepPurple,
                child: const Icon(Icons.bug_report),
              ),
            );

          case DebugRunState.running:
            final progress = runner.totalSteps > 0
                ? runner.currentStep / runner.totalSteps
                : 0.0;
            return Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Card(
                color: Colors.black87,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.bug_report, color: Colors.deepPurple, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Debug Runner',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.white),
                          ),
                          const Spacer(),
                          Text(
                            '${runner.currentStep}/${runner.totalSteps}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        runner.statusMessage,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            );

          case DebugRunState.completed:
            return Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Card(
                color: Colors.green.shade900,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          runner.statusMessage,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );

          case DebugRunState.error:
            return Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Card(
                color: Colors.red.shade900,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          runner.errorMessage ?? 'Unknown error',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
        }
      },
    );
  }
}

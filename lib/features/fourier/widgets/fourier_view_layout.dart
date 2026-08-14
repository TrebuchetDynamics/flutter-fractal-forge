import 'package:flutter/material.dart';

/// Presents the unchanged spatial renderer beside its Fourier magnitude.
///
/// The caller owns both children. In particular, the spatial renderer remains
/// mounted and paintable so gestures and subsequent captures continue while the
/// spectrum is visible.
class FourierViewLayout extends StatelessWidget {
  const FourierViewLayout({
    super.key,
    required this.spatial,
    required this.spectrum,
  });

  final Widget spatial;
  final Widget spectrum;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final landscape = constraints.maxWidth > constraints.maxHeight;
        final children = <Widget>[
          Expanded(
            child: _LabeledFourierPane(
              semanticsLabel: 'Spatial view',
              child: spatial,
            ),
          ),
          SizedBox(
            width: landscape ? 1 : null,
            height: landscape ? null : 1,
            child: const ColoredBox(color: Colors.white24),
          ),
          Expanded(
            child: _LabeledFourierPane(
              semanticsLabel: 'Fourier magnitude',
              child: spectrum,
            ),
          ),
        ];
        return landscape
            ? Row(
                key: const ValueKey('fourierLandscapeSplit'),
                children: children,
              )
            : Column(
                key: const ValueKey('fourierPortraitSplit'),
                children: children,
              );
      },
    );
  }
}

class _LabeledFourierPane extends StatelessWidget {
  const _LabeledFourierPane({
    required this.semanticsLabel,
    required this.child,
  });

  final String semanticsLabel;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      excludeSemantics: true,
      label: semanticsLabel,
      image: true,
      child: Stack(
        fit: StackFit.expand,
        children: [
          child,
          Positioned(
            left: 8,
            top: MediaQuery.paddingOf(context).top + 8,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.68),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  child: Text(
                    semanticsLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

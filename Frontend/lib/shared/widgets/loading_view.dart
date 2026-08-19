import 'package:flutter/material.dart';
import '../../app/theme/app_radii.dart';
import '../../app/theme/app_spacing.dart';

class LoadingView extends StatefulWidget {
  const LoadingView({super.key, this.lines = 4});
  final int lines;

  @override
  State<LoadingView> createState() => _LoadingViewState();
}

class _LoadingViewState extends State<LoadingView> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.outlineVariant;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final opacity = 0.4 + (0.3 * (0.5 + 0.5 * (_controller.value * 2 - 1).abs() * -1 + 0.5));
        return LayoutBuilder(
          builder: (context, constraints) {
            final tightHeight =
                constraints.maxHeight.isFinite && constraints.maxHeight < 96;
            final pad = tightHeight ? 0.0 : AppSpacing.md;
            final gap = tightHeight ? 8.0 : AppSpacing.md;
            final usable = tightHeight
                ? constraints.maxHeight
                : (widget.lines * 72.0) + (gap * (widget.lines - 1));
            final barHeight =
                ((usable - gap * (widget.lines - 1)) / widget.lines).clamp(8.0, 72.0);

            return Padding(
              padding: EdgeInsets.all(pad),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(widget.lines, (i) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: i == widget.lines - 1 ? 0 : gap),
                    child: Container(
                      height: barHeight,
                      decoration: BoxDecoration(
                        color: base.withValues(alpha: opacity.clamp(0.15, 0.5)),
                        borderRadius: AppRadii.lgRadius,
                      ),
                    ),
                  );
                }),
              ),
            );
          },
        );
      },
    );
  }
}

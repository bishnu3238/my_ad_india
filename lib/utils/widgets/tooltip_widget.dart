import 'package:flutter/material.dart';

class SimpleTooltip extends StatelessWidget {
  final Widget child;
  final String message;
  final TooltipDirection direction;

  const SimpleTooltip({
    super.key,
    required this.child,
    required this.message,
    this.direction = TooltipDirection.above,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onLongPress: () {
        final overlay = Overlay.of(context);
        final renderBox = context.findRenderObject() as RenderBox;
        final offset = renderBox.localToGlobal(Offset.zero);

        final entry = OverlayEntry(
          builder: (context) => Positioned(
            left: offset.dx,
            top: direction == TooltipDirection.above
                ? offset.dy - 40
                : offset.dy + renderBox.size.height + 8,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ),
          ),
        );

        overlay.insert(entry);
        Future.delayed(const Duration(seconds: 2), entry.remove);
      },
      child: child,
    );
  }
}

enum TooltipDirection { above, below }

import 'package:flutter/material.dart';

class UserGuideOverlay extends StatefulWidget {
  final List<UserGuideStep> steps;
  final VoidCallback onFinish;

  const UserGuideOverlay({
    super.key,
    required this.steps,
    required this.onFinish,
  });

  @override
  State<UserGuideOverlay> createState() => _UserGuideOverlayState();
}

class _UserGuideOverlayState extends State<UserGuideOverlay> {
  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    final step = widget.steps[_currentStep];
    return Stack(
      children: [
        // Dim background
        GestureDetector(
          onTap: () {},
          child: Container(
            color: Colors.black.withValues(alpha: 0.6),
          ),
        ),
        // Highlighted area
        Positioned(
          left: step.rect.left - 8,
          top: step.rect.top - 8,
          width: step.rect.width + 16,
          height: step.rect.height + 16,
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.orange, width: 3),
                borderRadius: BorderRadius.circular(12),
                color: Colors.transparent,
              ),
            ),
          ),
        ),
        // Message box
        Positioned(
          left: step.rect.left,
          top: step.rect.bottom + 12,
          child: Material(
            color: Colors.transparent,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 260),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    step.description,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (_currentStep < widget.steps.length - 1)
                        TextButton(
                          onPressed: () => setState(() => _currentStep++),
                          child: const Text('Next'),
                        ),
                      if (_currentStep == widget.steps.length - 1)
                        TextButton(
                          onPressed: widget.onFinish,
                          child: const Text('Finish'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class UserGuideStep {
  final Rect rect;
  final String title;
  final String description;

  UserGuideStep({
    required this.rect,
    required this.title,
    required this.description,
  });
}

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ImprovedProgressIndicator extends StatefulWidget {
  final int currentStep;
  final List<String> stepLabels;
  final List<IconData> stepIcons;
  final Function(int)? onStepTap;

  const ImprovedProgressIndicator({
    super.key,
    required this.currentStep,
    this.stepLabels = const ['Basic', 'Details', 'Media', 'Review'],
    this.stepIcons = const [
      Icons.home_rounded,
      Icons.description_rounded,
      Icons.photo_library_rounded,
      Icons.check_circle_rounded,
    ],
    this.onStepTap,
  });

  @override
  State<ImprovedProgressIndicator> createState() =>
      _ImprovedProgressIndicatorState();
}

class _ImprovedProgressIndicatorState extends State<ImprovedProgressIndicator>
    with TickerProviderStateMixin {
  // Controllers for the ripple effects
  Map<int, AnimationController> _rippleControllers = {};

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  @override
  void didUpdateWidget(ImprovedProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Trigger animation when current step changes
    if (oldWidget.currentStep != widget.currentStep) {
      _playRippleAnimation(widget.currentStep);
    }

    // Handle changes in the number of steps
    if (oldWidget.stepIcons.length != widget.stepIcons.length) {
      _disposeControllers();
      _initializeControllers();
    }
  }

  void _initializeControllers() {
    for (int i = 0; i < widget.stepIcons.length; i++) {
      _rippleControllers[i] = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1000),
      );
    }
    // Play animation for current step on initial load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playRippleAnimation(widget.currentStep);
    });
  }

  void _disposeControllers() {
    for (var controller in _rippleControllers.values) {
      controller.dispose();
    }
    _rippleControllers.clear();
  }

  void _playRippleAnimation(int stepIndex) {
    if (_rippleControllers.containsKey(stepIndex)) {
      _rippleControllers[stepIndex]!.reset();
      _rippleControllers[stepIndex]!.forward();
      HapticFeedback.lightImpact(); // Add haptic feedback
    }
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
        child: Column(
          children: [
            // Icons and connector lines
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: List.generate(widget.stepIcons.length * 2 - 1, (index) {
                // Even indices (0, 2, 4, 6) are icons
                if (index % 2 == 0) {
                  final stepIndex = index ~/ 2;
                  final isCompleted = stepIndex < widget.currentStep;
                  final isActive = stepIndex == widget.currentStep;

                  return Expanded(
                    child: _buildStepIndicator(
                      stepIndex: stepIndex,
                      isCompleted: isCompleted,
                      isActive: isActive,
                    ),
                  );
                } else {
                  // Odd indices (1, 3, 5) are connector lines
                  final lineIndex = index ~/ 2;
                  final isCompleted = lineIndex < widget.currentStep;

                  return Expanded(
                    child: _buildConnectorLine(isCompleted: isCompleted),
                  );
                }
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator({
    required int stepIndex,
    required bool isCompleted,
    required bool isActive,
  }) {
    // Use ripple animation for active step
    return GestureDetector(
      onTap:
          widget.onStepTap != null
              ? () {
                widget.onStepTap!(stepIndex);
                _playRippleAnimation(stepIndex);
              }
              : null,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // Ripple animation
              if (isActive)
                AnimatedBuilder(
                  animation: _rippleControllers[stepIndex]!,
                  builder: (context, child) {
                    return Container(
                      width:
                          50 * (1 + _rippleControllers[stepIndex]!.value * 0.5),
                      height:
                          50 * (1 + _rippleControllers[stepIndex]!.value * 0.5),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(
                          0.3 * (1 - _rippleControllers[stepIndex]!.value),
                        ),
                        shape: BoxShape.circle,
                      ),
                    );
                  },
                ),

              // Inner circle
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color:
                      isCompleted || isActive
                          ? Colors.blue
                          : Colors.grey.shade200,
                  shape: BoxShape.circle,
                  boxShadow:
                      isActive
                          ? [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.5),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ]
                          : null,
                  border: Border.all(
                    color:
                        isCompleted || isActive
                            ? Colors.blue
                            : Colors.grey.shade300,
                    width: 2,
                  ),
                ),
                child: Icon(
                  widget.stepIcons[stepIndex],
                  color:
                      isCompleted || isActive
                          ? Colors.white
                          : Colors.grey.shade600,
                  size: 22,
                ),
              ),

              // Checkmark overlay for completed steps
              if (isCompleted)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          // Step label
          AutoSizeText(
            widget.stepLabels[stepIndex],
            maxLines: 1,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color:
                  isCompleted || isActive ? Colors.blue : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectorLine({required bool isCompleted}) {
    return Container(
      height: 3,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      // Center the line vertically with icons
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient:
            isCompleted
                ? const LinearGradient(colors: [Colors.blue, Colors.blue])
                : LinearGradient(
                  colors: [Colors.grey.shade300, Colors.grey.shade300],
                ),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}

// Example usage:
class ProgressIndicatorExample extends StatefulWidget {
  const ProgressIndicatorExample({super.key});

  @override
  State<ProgressIndicatorExample> createState() =>
      _ProgressIndicatorExampleState();
}

class _ProgressIndicatorExampleState extends State<ProgressIndicatorExample> {
  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enhanced Progress Indicator')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ImprovedProgressIndicator(
              currentStep: _currentStep,
              stepLabels: const ['Basic', 'Details', 'Media', 'Review'],
              stepIcons: const [
                Icons.home_rounded,
                Icons.description_rounded,
                Icons.photo_library_rounded,
                Icons.check_circle_rounded,
              ],
              onStepTap: (index) {
                setState(() {
                  _currentStep = index;
                });
              },
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed:
                      _currentStep > 0
                          ? () {
                            setState(() {
                              _currentStep--;
                            });
                          }
                          : null,
                  child: const Text('Previous'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed:
                      _currentStep < 3
                          ? () {
                            setState(() {
                              _currentStep++;
                            });
                          }
                          : null,
                  child: const Text('Next'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

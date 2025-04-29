import 'package:flutter/material.dart';
import 'body/intro_body.dart';
import 'package:pack/pack.dart';
import '../../core/injector/dependency_injection.dart';
import 'core/intro_provider.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;
  late IntroProvider _introProvider;

  @override
  void initState() {
    super.initState();
    _introProvider = DependencyInjector.get<IntroProvider>();
    // Delay fetchData until after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _introProvider..fetchData(context)..initUserOrMerchant(context);
      }
    });
    // Wave animation controller
    _waveController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Wave Background Animation
          AnimatedBuilder(
            animation: _waveController,
            builder: (context, child) {
              return CustomPaint(
                painter: WaveBackgroundPainter(
                  animationValue: _waveController.value,
                  baseColor: theme.colorScheme.primary,
                ),
                child: Container(),
              );
            },
          ),

          // Main Content
          IntroBody(),
        ],
      ),
    );
  }
}

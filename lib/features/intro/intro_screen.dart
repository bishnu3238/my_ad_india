import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pack/pack.dart';
import '../../core/injector/dependency_injection.dart';
import '../../core/constant/image.dart';
import '../../core/theme/app_color_palette.dart';
import 'core/intro_provider.dart';

class IntroScreen extends StatefulWidget {
    IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen>
    with SingleTickerProviderStateMixin {
  late IntroProvider _introProvider;

  @override
  void initState() {
    super.initState();
    _introProvider = DependencyInjector.get<IntroProvider>();

    // Delay fetchData until after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _introProvider.fetchData(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: ChangeNotifierProvider.value(
        value: _introProvider,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Gradient background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primaryBlue.withValues(alpha: 0.95),
                    AppColors.purpleDeep.withValues(alpha: 0.85),
                  ],
                ),
              ),
            ),

            // Connection dots background animation
            Positioned.fill(child: ConnectionNetworkAnimation()),
            Positioned(
              bottom: 10,
              child: SizedBox(
                width: screenSize.width,
                height: screenSize.height * 0.2,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 50,
                      height: 50,
                      child: LocationRippleAnimation(size: 20),
                    ),
                  ],
                ),
              ),
            ),

            // Main Content
            SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Hero(
                        tag: 'app_logo',
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 24,
                          child: ImageView(
                            source: ImageSource.asset,
                            path: AppImage.logo,
                            width: 32,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Add, Discover, Connect',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          color: context.colorScheme.surface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Dynamic connection network animation
class ConnectionNetworkAnimation extends StatefulWidget {
  const ConnectionNetworkAnimation({super.key});

  @override
  State<ConnectionNetworkAnimation> createState() =>
      _ConnectionNetworkAnimationState();
}

class _ConnectionNetworkAnimationState extends State<ConnectionNetworkAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: NetworkPainter(animationValue: _controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class NetworkPainter extends CustomPainter {
  final double animationValue;

  NetworkPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white.withOpacity(0.15)
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke;

    final dotPaint =
        Paint()
          ..color = Colors.white.withOpacity(0.3)
          ..style = PaintingStyle.fill;

    // Create a network of dots with connecting lines
    List<Offset> points = [];
    final random = DateTime.now().millisecondsSinceEpoch;

    // Generate points
    for (int i = 0; i < 12; i++) {
      double x = ((random + i * 100) % size.width.toInt()).toDouble();
      double y = ((random + i * 200) % size.height.toInt()).toDouble();

      // Add animated movement
      x += sin((animationValue * 2 * 3.14) + i) * 20;
      y += cos((animationValue * 2 * 3.14) + i * 0.5) * 20;

      points.add(Offset(x, y));
    }

    // Draw connections between points
    for (int i = 0; i < points.length; i++) {
      for (int j = i + 1; j < points.length; j++) {
        double distance = (points[i] - points[j]).distance;

        // Only connect points within a certain distance
        if (distance < size.width * 0.3) {
          // Make line opacity based on distance
          double opacity = 1.0 - (distance / (size.width * 0.3));
          paint.color = Colors.white.withOpacity(opacity * 0.15);

          canvas.drawLine(points[i], points[j], paint);
        }
      }
    }

    // Draw dots
    for (var point in points) {
      // Animated pulse effect for dots
      double radius =
          3.5 + sin((animationValue * 2 * 3.14) + points.indexOf(point)) * 1.5;
      canvas.drawCircle(point, radius, dotPaint);
    }
  }

  @override
  bool shouldRepaint(NetworkPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

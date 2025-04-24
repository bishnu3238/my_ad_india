import 'dart:developer' as dev;
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_ad/core/constant/image.dart';
import 'package:pack/pack.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';

// First-time popup handler
class FirstTimePopupManager {
  static const String _hasShownPopupKey = 'has_shown_referral_popup';

  static Future<bool> shouldShowPopup() async {
    final prefs = await SharedPreferences.getInstance();
    dev.log(
      'has_shown_referral_popup = ${(prefs.getBool(_hasShownPopupKey)!)}',
    );
    final hasShown = prefs.getBool(_hasShownPopupKey) ?? true;

    return hasShown ? hasShown : true;
  }

  static Future<void> markPopupAsShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasShownPopupKey, true);
  }

  static Future<void> showReferralPopupIfNeeded(BuildContext context) async {
    if (await shouldShowPopup()) {
      // Wait for the build to complete before showing dialog
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showReferralPopup(context);
      });
      await markPopupAsShown();
    }
  }

  static void _showReferralPopup(BuildContext homeContext) {
    showGeneralDialog(
      context: homeContext,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder:
          (_, __, ___) => AnimatedReferralPopup(homeContext: homeContext),
      transitionBuilder: (_, animation, __, child) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.elasticOut,
            reverseCurve: Curves.easeOutCubic,
          ),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
    );
  }
}

class AnimatedReferralPopup extends StatefulWidget {
  const AnimatedReferralPopup({super.key, required this.homeContext});
  final BuildContext homeContext;

  @override
  State<AnimatedReferralPopup> createState() => _AnimatedReferralPopupState();
}

class _AnimatedReferralPopupState extends State<AnimatedReferralPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _confettiController;
  final List<ConfettiParticle> _particles = [];

  @override
  void initState() {
    super.initState();
    _confettiController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _confettiController.forward();
    _generateConfetti();

    // Vibrate for tactile feedback
    HapticFeedback.mediumImpact();
  }

  void _generateConfetti() {
    const int particleCount = 60;

    for (int i = 0; i < particleCount; i++) {
      _particles.add(
        ConfettiParticle(
          color: Color(
            (math.Random().nextDouble() * 0xFFFFFF).toInt(),
          ).withValues(alpha: 1.0),
          position: Offset(
            math.Random().nextDouble() * 300,
            -20 - math.Random().nextDouble() * 40,
          ),
          velocity: Offset(
            (math.Random().nextDouble() - 0.5) * 8,
            3 + math.Random().nextDouble() * 5,
          ),
          size: 5 + math.Random().nextDouble() * 8,
          angle: math.Random().nextDouble() * math.pi * 2,
          angularVelocity: (math.Random().nextDouble() - 0.5) * 0.2,
        ),
      );
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Stack(
          alignment: Alignment.center,

          children: [
            // Confetti animation
            AnimatedBuilder(
              animation: _confettiController,

              builder: (context, _) {
                return CustomPaint(
                  size: Size(MediaQuery.of(context).size.width, 300),
                  painter: ConfettiPainter(
                    particles: _particles,
                    progress: _confettiController.value,
                  ),
                );
              },
            ),
            // Main popup card
            Container(
              width: MediaQuery.of(context).size.width * 0.85,
              height: MediaQuery.of(context).size.height * 0.72,
              constraints: const BoxConstraints(maxWidth: 360),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  children: [
                    // Background gradient
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.purple.shade800,
                            Colors.deepPurple.shade700,
                            Colors.indigo.shade600,
                          ],
                        ),
                      ),
                    ),
                    // Decorative shapes
                    Positioned(
                      top: -50,
                      left: -50,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -30,
                      right: -30,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                    // Content container
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Top section with coins animation
                        SizedBox(
                          height: 180,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Coin shower animation
                              CoinShowerAnimation(),
                              // Glow effect
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      Colors.yellow.withValues(alpha: 0.7),
                                      Colors.yellow.withValues(alpha: 0),
                                    ],
                                  ),
                                ),
                              ),
                              // Gift icon
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.orange.shade300,
                                      Colors.orange.shade700,
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.orange.withValues(
                                        alpha: 0.5,
                                      ),
                                      blurRadius: 15,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: ImageView(
                                  source: ImageSource.asset,
                                  path: AppImage.logo,
                                  shape: ImageShape.circle,
                                  height: 50,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Text content
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            children: [
                              // Title with bouncing animation
                              TitleWithBounceAnimation(
                                title: "Refer & Earn Rewards!",
                              ),
                              const SizedBox(height: 16),
                              // Description
                              Text(
                                "Invite friends, earn money, and unlock exclusive benefits. Start your journey as an agent today!",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 16,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 24),
                              // Benefit points
                              ReferralBenefitPoint(
                                icon: Icons.monetization_on_rounded,
                                text: "Earn for every friend who joins",
                              ),
                              const SizedBox(height: 8),
                              ReferralBenefitPoint(
                                icon: Icons.upgrade_rounded,
                                text: "Unlock special agent status",
                              ),
                              const SizedBox(height: 24),
                              // Buttons
                              Row(
                                children: [
                                  // "Maybe Later" button
                                  Expanded(
                                    child: MaterialButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        side: BorderSide(
                                          color: Colors.white.withValues(
                                            alpha: 0.3,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        "Maybe Later",
                                        style: TextStyle(
                                          color: Colors.white.withValues(
                                            alpha: 0.7,
                                          ),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // "Know More" button
                                  Expanded(
                                    child: MaterialButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        widget.homeContext.push(
                                          '/terms-and-conditions',
                                        );
                                      },
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      color: Colors.orange.shade500,
                                      elevation: 0,
                                      child: const Text(
                                        "Know More",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Title with bounce animation
class TitleWithBounceAnimation extends StatefulWidget {
  final String title;

  const TitleWithBounceAnimation({Key? key, required this.title})
    : super(key: key);

  @override
  State<TitleWithBounceAnimation> createState() =>
      _TitleWithBounceAnimationState();
}

class _TitleWithBounceAnimationState extends State<TitleWithBounceAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.2), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 0.85), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.85, end: 1.1), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.1, end: 1.0), weight: 1),
    ]).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );

    _bounceController.forward();
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bounceAnimation,
      builder: (context, child) {
        return Transform.scale(scale: _bounceAnimation.value, child: child);
      },
      child: ShaderMask(
        shaderCallback: (bounds) {
          return LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.orange.shade300, Colors.yellow.shade300],
          ).createShader(bounds);
        },
        child: Text(
          widget.title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

// Referral benefit point
class ReferralBenefitPoint extends StatelessWidget {
  final IconData icon;
  final String text;

  const ReferralBenefitPoint({Key? key, required this.icon, required this.text})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.orange.shade300, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}

// Confetti particle
class ConfettiParticle {
  Color color;
  Offset position;
  Offset velocity;
  double size;
  double angle;
  double angularVelocity;

  ConfettiParticle({
    required this.color,
    required this.position,
    required this.velocity,
    required this.size,
    required this.angle,
    required this.angularVelocity,
  });
}

// Confetti painter
class ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;
  final double progress;

  ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (var particle in particles) {
      final effectivePosition = Offset(
        particle.position.dx +
            (particle.velocity.dx * progress * size.width / 2),
        particle.position.dy +
            (particle.velocity.dy * progress * size.height / 2),
      );

      if (effectivePosition.dy > size.height) continue;

      paint.color = particle.color;

      canvas.save();
      canvas.translate(effectivePosition.dx, effectivePosition.dy);
      canvas.rotate(particle.angle + particle.angularVelocity * progress * 10);

      // Draw different confetti shapes
      final random = math.Random(particles.indexOf(particle));
      final shape = random.nextInt(3);

      switch (shape) {
        case 0: // Rectangle
          canvas.drawRect(
            Rect.fromCenter(
              center: Offset.zero,
              width: particle.size,
              height: particle.size * 0.5,
            ),
            paint,
          );
          break;
        case 1: // Circle
          canvas.drawCircle(Offset.zero, particle.size / 2, paint);
          break;
        case 2: // Triangle
          final path = Path();
          path.moveTo(0, -particle.size / 2);
          path.lineTo(particle.size / 2, particle.size / 2);
          path.lineTo(-particle.size / 2, particle.size / 2);
          path.close();
          canvas.drawPath(path, paint);
          break;
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) => true;
}

// Animated coin shower
class CoinShowerAnimation extends StatefulWidget {
  const CoinShowerAnimation({Key? key}) : super(key: key);

  @override
  State<CoinShowerAnimation> createState() => _CoinShowerAnimationState();
}

class _CoinShowerAnimationState extends State<CoinShowerAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<CoinParticle> _coins = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _generateCoins();
    _controller.forward();
  }

  void _generateCoins() {
    for (int i = 0; i < 20; i++) {
      _coins.add(
        CoinParticle(
          position: Offset(
            math.Random().nextDouble() * 300 - 50,
            -100 - math.Random().nextDouble() * 200,
          ),
          velocity: Offset(
            (math.Random().nextDouble() - 0.5) * 3,
            8 + math.Random().nextDouble() * 10,
          ),
          size: 18 + math.Random().nextDouble() * 10,
          rotationSpeed: (math.Random().nextDouble() - 0.5) * 0.3,
          rotation: math.Random().nextDouble() * math.pi * 2,
          delay: math.Random().nextDouble() * 0.5,
        ),
      );
    }
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
      builder: (context, _) {
        return CustomPaint(
          size: const Size(300, 180),
          painter: CoinShowerPainter(
            coins: _coins,
            progress: _controller.value,
          ),
        );
      },
    );
  }
}

// Coin particle
class CoinParticle {
  Offset position;
  Offset velocity;
  double size;
  double rotation;
  double rotationSpeed;
  double delay;

  CoinParticle({
    required this.position,
    required this.velocity,
    required this.size,
    required this.rotation,
    required this.rotationSpeed,
    required this.delay,
  });
}

// Coin shower painter
class CoinShowerPainter extends CustomPainter {
  final List<CoinParticle> coins;
  final double progress;

  CoinShowerPainter({required this.coins, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (var coin in coins) {
      final effectiveProgress = math.max(0.0, progress - coin.delay);
      if (effectiveProgress <= 0) continue;

      final adjustedProgress = effectiveProgress / (1 - coin.delay);

      final effectivePosition = Offset(
        coin.position.dx +
            (coin.velocity.dx * adjustedProgress * size.width / 5),
        coin.position.dy +
            (coin.velocity.dy * adjustedProgress * size.height / 3),
      );

      if (effectivePosition.dy > size.height) continue;

      // Draw the coin with a gold gradient
      canvas.save();
      canvas.translate(effectivePosition.dx, effectivePosition.dy);

      // Apply rotation to simulate spinning
      canvas.rotate(coin.rotation + coin.rotationSpeed * adjustedProgress * 10);

      // Calculate ellipse shape based on rotation to simulate 3D effect
      final squish = math.sin(coin.rotation * 2) * 0.5 + 0.5;
      final width = coin.size;
      final height = coin.size * (0.5 + squish * 0.5);

      // Gold gradient
      final coinPaint =
          Paint()
            ..shader = RadialGradient(
              colors: [Colors.yellow.shade300, Colors.orange.shade700],
              stops: const [0.7, 1.0],
            ).createShader(
              Rect.fromLTWH(-width / 2, -height / 2, width, height),
            );

      // Highlight
      final highlightPaint =
          Paint()
            ..color = Colors.white.withValues(alpha: 0.6)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5;

      // Draw the coin
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: width, height: height),
        coinPaint,
      );

      // Draw the highlight
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(-width / 6, -height / 6),
          width: width * 0.5,
          height: height * 0.5,
        ),
        math.pi * 0.8,
        math.pi * 0.6,
        false,
        highlightPaint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(CoinShowerPainter oldDelegate) => true;
}

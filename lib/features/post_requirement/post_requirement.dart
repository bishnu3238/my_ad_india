import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:go_router/go_router.dart';
import 'package:my_ad/features/merchant/core/merchant_navigation.dart';

class ServiceProviderGuidePage extends StatefulWidget {
  const ServiceProviderGuidePage({Key? key}) : super(key: key);

  @override
  _ServiceProviderGuidePageState createState() =>
      _ServiceProviderGuidePageState();
}

class _ServiceProviderGuidePageState extends State<ServiceProviderGuidePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  int _currentStep = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  final List<Map<String, dynamic>> _steps = [
    {
      'title': 'Select Service Category',
      'description':
          'Choose your business category and specific service from our wide range of options.',
      'icon': Icons.category,
      'color': Colors.blue,
    },
    {
      'title': 'Personal Information',
      'description':
          'Fill in your personal details including name, contact number, email, and gender.',
      'icon': Icons.person,
      'color': Colors.blue,
    },
    {
      'title': 'Business Details',
      'description':
          'Provide your business name, address, and optional tax information like PAN and GSTIN numbers.',
      'icon': Icons.business,
      'color': Colors.blue,
    },
    {
      'title': 'Service Location',
      'description':
          'Set your service area to help customers find you based on their location.',
      'icon': Icons.location_on,
      'color': Colors.blue,
    },
    {
      'title': 'Account Setup',
      'description':
          'Create your password, add an optional referral code, and select your subscription plan.',
      'icon': Icons.security,
      'color': Colors.blue,
    },
  ];

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() {
        _currentStep++;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Navigate to registration form
      context.push(MerchantRoute.merchantRegister);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentStep = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Become a Service Provider',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 15.0,
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    _steps.length,
                    (index) => _buildStepIndicator(index),
                  ),
                ),
                const SizedBox(height: 8),
                StepProgressIndicator(
                  currentStep: _currentStep,
                  totalSteps: _steps.length,
                ),
              ],
            ),
          ),

          // Main content
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: _onPageChanged,
              itemCount: _steps.length,
              itemBuilder: (context, index) {
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      // Header with animated painter
                      Container(
                        height: 170,
                        margin: const EdgeInsets.all(20),
                        child: Stack(
                          children: [
                            CustomPaint(
                              size: const Size(double.infinity, 150),
                              painter: BackgroundPainter(
                                animation: _animationController,
                              ),
                            ),
                            Center(
                              child: AnimatedBuilder(
                                animation: _animationController,
                                builder: (context, child) {
                                  return Transform.rotate(
                                    angle:
                                        _animationController.value *
                                        2 *
                                        math.pi,
                                    child: child,
                                  );
                                },
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: _steps[index]['color']
                                            .withOpacity(0.3),
                                        blurRadius: 10,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    _steps[index]['icon'],
                                    size: 50,
                                    color: _steps[index]['color'],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Step title and description
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          children: [
                            Text(
                              _steps[index]['title'],
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _steps[index]['description'],
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      // Benefits and information section
                      _buildStepDetails(index),
                    ],
                  ),
                );
              },
            ),
          ),

          // Navigation buttons
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: _previousStep,
                  icon: const Icon(Icons.arrow_back),
                  label: Text(_currentStep == 0 ? 'Cancel' : 'Back'),
                ),
                ElevatedButton(
                  onPressed: _nextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _currentStep == _steps.length - 1
                            ? 'Get Started'
                            : 'Next',
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int index) {
    bool isCompleted = index < _currentStep;
    bool isCurrent = index == _currentStep;

    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:
                isCompleted
                    ? Colors.blue
                    : isCurrent
                    ? Colors.blue.shade100
                    : Colors.grey.shade200,
            border: Border.all(
              color: isCurrent ? Colors.blue : Colors.transparent,
              width: 2,
            ),
          ),
          child: Center(
            child:
                isCompleted
                    ? const Icon(Icons.check, color: Colors.white)
                    : Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: isCurrent ? Colors.blue : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCurrent ? Colors.blue : Colors.transparent,
          ),
        ),
      ],
    );
  }

  Widget _buildStepDetails(int index) {
    final List<Map<String, dynamic>> details = _getStepDetails(index);

    return Container(
      margin: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'What you need:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            ),
          ),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: details.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, idx) {
              return ListTile(
                leading: Icon(details[idx]['icon'], color: Colors.blue),
                title: Text(details[idx]['title']),
                subtitle: Text(details[idx]['description']),
              );
            },
          ),
          if (index == _steps.length - 1)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb, color: Colors.orange.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'After registration, our team will verify your details within 24 hours to activate your account.',
                        style: TextStyle(color: Colors.orange.shade800),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getStepDetails(int index) {
    switch (index) {
      case 0:
        return [
          {
            'icon': Icons.category_outlined,
            'title': 'Choose your category',
            'description':
                'Select from options like Blogger, Dropshipper, etc.',
          },
          {
            'icon': Icons.list_alt,
            'title': 'Select specific service',
            'description': 'Tell us what specific services you offer',
          },
        ];
      case 1:
        return [
          {
            'icon': Icons.person_outline,
            'title': 'Full Name',
            'description': 'Your complete name as shown on your ID',
          },
          {
            'icon': Icons.phone_android,
            'title': 'Mobile Number',
            'description': 'Working phone number for verification',
          },
          {
            'icon': Icons.email_outlined,
            'title': 'Email Address',
            'description': 'Valid email for important notifications',
          },
        ];
      case 2:
        return [
          {
            'icon': Icons.business,
            'title': 'Business Name',
            'description': 'Your company or brand name',
          },
          {
            'icon': Icons.location_city,
            'title': 'Business Address',
            'description': 'Address where you operate your business',
          },
          {
            'icon': Icons.receipt_long,
            'title': 'Tax Information',
            'description': 'Optional PAN and GSTIN numbers',
          },
        ];
      case 3:
        return [
          {
            'icon': Icons.map_outlined,
            'title': 'Service Area',
            'description': 'Define where you can provide your services',
          },
          {
            'icon': Icons.my_location,
            'title': 'Exact Location',
            'description': 'Allow precise location for better visibility',
          },
        ];
      case 4:
        return [
          {
            'icon': Icons.lock_outline,
            'title': 'Secure Password',
            'description': 'Create a strong password for your account',
          },
          {
            'icon': Icons.card_membership,
            'title': 'Subscription Plan',
            'description': 'Choose a plan based on your business needs',
          },
          {
            'icon': Icons.verified_user_outlined,
            'title': 'Terms & Conditions',
            'description': 'Review and accept our platform policies',
          },
        ];
      default:
        return [];
    }
  }
}

class StepProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const StepProgressIndicator({
    Key? key,
    required this.currentStep,
    required this.totalSteps,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 6,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(3),
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width:
                MediaQuery.of(context).size.width *
                (currentStep + 1) /
                totalSteps *
                0.85, // Adjust for padding
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade400, Colors.blue.shade700],
              ),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ],
      ),
    );
  }
}

class BackgroundPainter extends CustomPainter {
  final Animation animation;

  BackgroundPainter({required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..shader = LinearGradient(
            colors: [Colors.blue.shade100, Colors.blue.shade200],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // Base shape
    final path =
        Path()
          ..moveTo(0, size.height * 0.7)
          ..quadraticBezierTo(
            size.width * 0.25,
            size.height * (0.7 + 0.1 * math.sin(animation.value * math.pi * 2)),
            size.width * 0.5,
            size.height * 0.7,
          )
          ..quadraticBezierTo(
            size.width * 0.75,
            size.height * (0.7 - 0.1 * math.sin(animation.value * math.pi * 2)),
            size.width,
            size.height * 0.7,
          )
          ..lineTo(size.width, size.height)
          ..lineTo(0, size.height)
          ..close();

    canvas.drawPath(path, paint);

    // Draw circles
    final circlePaint = Paint()..color = Colors.white.withOpacity(0.2);

    for (int i = 0; i < 5; i++) {
      final radius = 20.0 + i * 15.0;
      final offsetX =
          size.width * 0.2 + math.cos(animation.value * math.pi * 2 + i) * 20;
      final offsetY =
          size.height * 0.3 + math.sin(animation.value * math.pi * 2 + i) * 20;

      canvas.drawCircle(Offset(offsetX, offsetY), radius, circlePaint);
    }

    for (int i = 0; i < 5; i++) {
      final radius = 15.0 + i * 10.0;
      final offsetX =
          size.width * 0.8 + math.cos(animation.value * math.pi * 2 - i) * 15;
      final offsetY =
          size.height * 0.4 + math.sin(animation.value * math.pi * 2 - i) * 15;

      canvas.drawCircle(Offset(offsetX, offsetY), radius, circlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

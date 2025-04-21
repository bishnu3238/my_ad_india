import 'dart:ui';

import 'package:equatable/equatable.dart';

class OnboardingPageModel extends Equatable {
  final String title;
  final String description;
  final String illustrationPath;
  final Color startColor;
  final Color endColor;
  final int index;

  const OnboardingPageModel({
    required this.title,
    required this.description,
    required this.illustrationPath,
    required this.index,
    required this.startColor,
    required this.endColor,
  });

  @override
  List<Object?> get props => [title, description, illustrationPath, index];

  static List<OnboardingPageModel> get pages => [
    OnboardingPageModel(
      title: 'Discover Services',
      description: 'Explore a wide range of services from local merchants',
      illustrationPath: 'assets/Illustration/Illustration-4.png',
      index: 0,
      startColor: Color(0xFF8A4FFF),
      endColor: Color(0xFFFF5722),
    ),
    OnboardingPageModel(
      title: 'Connect Easily',
      description: 'Contact merchants directly with one tap',
      illustrationPath: 'assets/Illustration/Illustration-3.png',
      index: 1,
      startColor: Color(0xFF8A4FFF),
      endColor: Color(0xFFFF5722),
    ),
    OnboardingPageModel(
      title: 'Post Ad Your Own',
      description: 'List your services with our simple tools',
      illustrationPath: 'assets/Illustration/Illustration-1.png',
      index: 2,
      startColor: Color(0xFF8A4FFF),
      endColor: Color(0xFFFF5722),
    ),
  ];
}

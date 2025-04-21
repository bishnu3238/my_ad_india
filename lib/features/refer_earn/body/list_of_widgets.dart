import 'package:flutter/material.dart';

List<Widget> listOfWidgets = [
  Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF2E3192), Color(0xFF1BFFFF)],
      ),
    ),
  ),

  // Decorative Elements
  Positioned(
    top: -50,
    right: -50,
    child: Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.1),
      ),
    ),
  ),
  Positioned(
    bottom: -100,
    left: -50,
    child: Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.08),
      ),
    ),
  ),
];

// scroll_visibility_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ScrollVisibilityProvider extends ChangeNotifier {
  bool _isVisible = true;

  bool get isVisible => _isVisible;

  void updateVisibility(ScrollDirection direction) {
    final shouldBeVisible = direction != ScrollDirection.reverse;
    if (_isVisible != shouldBeVisible) {
      _isVisible = shouldBeVisible;
      notifyListeners();
    }
  }
}

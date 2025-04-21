import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingProvider with ChangeNotifier {
  int _currentPage = 0;
  bool _isOnboardingComplete = false;

  int get currentPage => _currentPage;
  bool get isOnboardingComplete => _isOnboardingComplete;

  void setCurrentPage(int page) {
    _currentPage = page;
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingComplete', true);
    _isOnboardingComplete = true;
    notifyListeners();
  }

  Future<bool> checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isOnboardingComplete = prefs.getBool('onboardingComplete') ?? false;
    return _isOnboardingComplete;
  }
}
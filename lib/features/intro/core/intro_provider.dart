import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
 import '../../../core/services/service.dart';
import '../../onboarding/core/onboarding_provider.dart';

class IntroProvider extends ChangeNotifier {
  final CityService _cityService;
  bool _isLoading = true;

  IntroProvider(this._cityService);

  bool get isLoading => _isLoading;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future fetchData(BuildContext context) async {
    setLoading(true);
      await Future.wait([_cityService.fetchCities()]);


    setLoading(false);
    if (context.mounted) navigateAfterFetch(context);
  }

  void navigateAfterFetch(BuildContext context) {
    final onboardingProvider = context.read<OnboardingProvider>();

    onboardingProvider.checkOnboardingStatus().then((isComplete) {
      if (context.mounted) {
         if (isComplete) {
          context.go('/home');
        } else {
          context.go('/onboarding');
        }
      }
    });
  }
}

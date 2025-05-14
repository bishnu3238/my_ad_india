import 'package:flutter/material.dart';
import 'package:pack/services/service.dart';

// import '../../utils/translation_service/easy_localize_app.dart';
import 'other_package_injection.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return OtherPackageInjection();
  }
}



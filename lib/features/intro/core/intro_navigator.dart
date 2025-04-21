import 'package:flutter/src/widgets/basic.dart';
import 'package:go_router/go_router.dart';
import 'package:pack/services/service.dart';

import '../intro_screen.dart';

class IntroRoute {
  static GoRoute page() =>
      GoRoute(path: '/', builder: (context, state) => ScreenUtils.builder(
        builder: (context) {
          return IntroScreen();
        }
      ));
}

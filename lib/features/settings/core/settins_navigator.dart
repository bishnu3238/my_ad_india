import 'package:go_router/go_router.dart';
import 'package:my_ad/features/settings/settings.dart';

class SettingNavigator {
  static const String _root = '/setting';
  static const String appSettings = '/setting/setting';

  static GoRoute page() =>
      GoRoute(path: _root, builder: (ctx, state) => SettingsScreen());
}

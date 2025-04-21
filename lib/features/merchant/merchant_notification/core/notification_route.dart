import 'package:go_router/go_router.dart';

import '../notification_page.dart';

class NotificationRoute{

  static const String notification = '/notification';

  static GoRoute page()=>GoRoute(
    path: notification,
    builder: (ctx, state)=>NotificationPage()
  );
}
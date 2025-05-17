import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/injector/dependency_injection.dart';
import '../ui/support_screen.dart';
import 'support_provider.dart';

class SupportNavigator {

static const String support = '/support';
static const String supportName = 'support';


static GoRoute page()=> GoRoute(path: support, name: supportName, builder: (context, state) {
  return ChangeNotifierProvider(
          create: (_) => DependencyInjector.get<SupportProvider>(),
          child: SupportScreen(),
        );
});

}

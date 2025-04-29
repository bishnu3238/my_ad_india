import 'package:go_router/go_router.dart';
import 'package:pack/extensions/mapx.dart';
import '../all_services.dart';

enum ShowServicesBy { category, subCategory, all, merchant }

class AllServicesRoute {
  static const String allServices = '/all-services';

  static GoRoute page() => GoRoute(
    path: '$allServices/:categoryId/:showServiceBy',

    pageBuilder: (context, state) {
      final showServiceBy = state.pathParameters.getEnum(
        'showServiceBy',
        ShowServicesBy.values,
        ShowServicesBy.all,
      );
      final categoryId = state.pathParameters.getString(
        'categoryId',
        showServiceBy == ShowServicesBy.all ? '' : '1',
      );
      return NoTransitionPage(
        child: AllServicesScreen(
          categoryId: categoryId,
          showServiceBy: showServiceBy,
        ),
      );
    },
  );
}

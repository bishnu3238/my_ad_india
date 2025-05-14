import 'package:go_router/go_router.dart';
import '../myad_categories_screen.dart';


class AllCategoriesRoute{
static const String allCategory = '/allCategory';
  static GoRoute page()=>GoRoute(
    path: allCategory,

    pageBuilder: (context, state) => NoTransitionPage(child: AllCategoriesScreen()),

  );

}
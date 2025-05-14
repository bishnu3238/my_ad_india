import 'package:go_router/go_router.dart';

import '../post_requirement.dart';

class PostRequirementRoute {
  static const String postRequirement = '/post-requirement';
  static const String postRequirementDetail = '/post-requirement-detail';

  static GoRoute page() => GoRoute(
    path: postRequirement,
    builder: (ctx, state) => ServiceProviderGuidePage(),
  );
}

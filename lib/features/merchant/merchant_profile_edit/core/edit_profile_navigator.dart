import 'package:go_router/go_router.dart';
import 'package:my_ad/features/merchant/merchant_profile_edit/profile_edit_screen.dart';

class EditMerchantProfileNavigator {
  static const String editPath = '/edit-merchant-profile';
  static const String editName = 'edit-merchant-profile';

  static GoRoute page() {
    return GoRoute(
      path: editPath,
      name: editName,
      builder: (context, state) {
        return const EditProfileScreen();
      },
    );
  }
}

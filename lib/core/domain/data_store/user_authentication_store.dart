import 'package:my_ad/core/data/model/model.dart';
import 'package:pack/services/base_services/base_service.dart';

class UserAuthenticationStore extends EntityStore<UserAuthModel> {
  UserAuthenticationStore() : super(initialEntity: const UserAuthModel());

  void setAuthenticated(
    UserModel user,
    bool isUserMerchant,
    String token, {
    DateTime? expiry,
  }) {
    setEntity(
      UserAuthModel(
        isAuthenticated: true,
        isUserMerchant: isUserMerchant,
        user: user,
        token: token,
        tokenExpiry: expiry ?? DateTime.now().add(const Duration(hours: 1)),
      ),
    );
  }

  void updateUser(UserModel user) {
    updateEntity(
      (current) =>
          current?.copyWith(user: user) ??
          UserAuthModel(isAuthenticated: true, user: user),
    );
  }

  void updatePreferences(UserPreferences preferences) {
    updateEntity((current) => current!.copyWith(preferences: preferences));
  }

  void logout() {
    setEntity(const UserAuthModel());
  }

  bool get isLoggedIn =>
      entity?.isAuthenticated == true && entity?.user != null;

  bool get isTokenExpired {
    final expiry = entity?.tokenExpiry;
    return expiry == null || DateTime.now().isAfter(expiry);
  }
}

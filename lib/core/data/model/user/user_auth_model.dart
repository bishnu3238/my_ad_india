import 'package:my_ad/core/data/model/model.dart';

class UserAuthModel {
  final bool isAuthenticated;
  final bool isUserMerchant;
  final UserModel? user;
  final String? token;
  final DateTime? tokenExpiry;
  final UserPreferences preferences;

  const UserAuthModel({
    this.isAuthenticated = false,
      this.isUserMerchant = false,
    this.user,
    this.token,
    this.tokenExpiry,
    this.preferences = const UserPreferences(),
  });

  UserAuthModel copyWith({
    bool? isAuthenticated,
    bool? isUserMerchant,
    UserModel? user,
    String? token,
    DateTime? tokenExpiry,
    UserPreferences? preferences,
  }) {
    return UserAuthModel(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isUserMerchant: isUserMerchant ?? this.isUserMerchant,
      user: user ?? this.user,
      token: token ?? this.token,
      tokenExpiry: tokenExpiry ?? this.tokenExpiry,
      preferences: preferences ?? this.preferences,
    );
  }
}
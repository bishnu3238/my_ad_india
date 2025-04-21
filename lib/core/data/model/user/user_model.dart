import '../../../../features/app_start/app.dart';
import 'dart:developer' as dev;
import 'package:pack/pack.dart';
import 'package:pack/auth/custom_auth.dart';

enum UserMetadata { phoneNo, gender, maretialStatus }

class UserModel implements UserEntity {
  @override
  final String id;

  @override
  final String name;

  @override
  final String email;

  @override
  final String? profileImage;

  @override
  final Map<String, dynamic>? metadata;

  final String? phoneNumber;

  static UserModel empty = UserModel(id: '', name: '', email: '');

  bool get isEmpty => id.isEmpty && name.isEmpty && email.isEmpty;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.profileImage,
    this.metadata,
    this.phoneNumber,
  });

  factory UserModel.fromJson(Map<String, dynamic> data) {
    dev.log('USER MODEL: "$data"');

    Map<String, dynamic> json = data['data']['user'];
    return UserModel(
      id: json.getString('id'),
      name: json.getString('name'),
      email: json.getString('email'),
      profileImage: json.getString('profile_image'),
      metadata: json.getMap('metadata'),
      phoneNumber: json.getString('mobile'),
    );
  }

  get isAuthenticated => (id.isNotEmpty && name.isNotEmpty)
     ;

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profile_image': profileImage,
      'metadata': metadata,
      'mobile': phoneNumber,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? profileImage,
    Map<String, dynamic>? metadata,
    String? phoneNumber,
  }) => UserModel(
    id: id ?? this.id,
    name: name ?? this.name,
    email: email ?? this.email,
    profileImage: profileImage ?? this.profileImage,
    metadata: metadata ?? this.metadata,
    phoneNumber: phoneNumber ?? this.phoneNumber,
  );

  @override
  String toString() {
    return 'UserModel{id: $id, name: $name, email: $email, profileImage: $profileImage, metadata: $metadata, phoneNumber: $phoneNumber}';
  }



  @override
  T fromMap<T>(Map<String, dynamic> json) {
    if (T == UserModel) {
      return UserModel(
        id: json.getString('id'),
        name: json.getString('name'),
        email: json.getString('email'),
        profileImage: json.getString('profile_image'),
        metadata: json.getMap('metadata'),
        phoneNumber: json.getString('mobile'),
      ) as T;
    }
    throw Exception('Type $T is not supported by UserModel.fromMap');
  }
}

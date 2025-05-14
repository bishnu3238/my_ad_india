import 'package:pack/extensions/extensions.dart';

class Customer {
  final String id;
  final String username;
  final String email;
  final String mobile;
  final String gender;
  final String? image;
  final String? address;
  final String? latitude;
  final String? longitude;
  final String createdAt;

  Customer({
    required this.id,
    required this.username,
    required this.email,
    required this.mobile,
    required this.gender,
    this.image,
    this.address,
    this.latitude,
    this.longitude,
    required this.createdAt,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json.getString('id'),
      username: json.getString('username'),
      email: json.getString('email'),
      mobile: json.getString('mobile'),
      gender: json.getString('gender'),
      image: json['image'] as String?,
      address: json['address'] as String?,
      latitude: json['latitude'] as String?,
      longitude: json['longitude'] as String?,
      createdAt: json.getString('created_at'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'mobile': mobile,
      'gender': gender,
      'image': image,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'created_at': createdAt,
    };
  }

  Customer copyWith({
    String? id,
    String? username,
    String? email,
    String? mobile,
    String? gender,
    String? image,
    String? address,
    String? latitude,
    String? longitude,
    String? createdAt,
  }) {
    return Customer(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      gender: gender ?? this.gender,
      image: image ?? this.image,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
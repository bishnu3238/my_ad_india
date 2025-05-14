

import 'package:equatable/equatable.dart';

class ChatUser  extends Equatable{
  final int id;
  final String userType; // 'customer' or 'merchant'
  final String username;
  final String email;
  final String? image; // customer: image, merchant: companyLogo
  final String? companyName; // merchant only
  final String? companyLogo; // merchant only
  final DateTime? createdAt;

 const  ChatUser({
    required this.id,
    required this.userType,
    required this.username,
    required this.email,
    this.image,
    this.companyName,
    this.companyLogo,
    this.createdAt,
  });

  factory ChatUser.fromJson(Map<String, dynamic> json) => ChatUser(
    id: json['id'],
    userType: json['userType'] ?? '',
    username: json['username'] ?? '',
    email: json['email'] ?? '',
    image: json['image'],
    companyName: json['companyName'],
    companyLogo: json['companyLogo'],
    createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
  );



  Map<String, dynamic> toJson() => {
    'id': id,
    'userType': userType,
    'username': username,
    'email': email,
    'image': image,
    'companyName': companyName,
    'companyLogo': companyLogo,
    'createdAt': createdAt?.toIso8601String(),
  };

  @override
  String toString() {
    return 'ChatUser{id: $id, userType: $userType, username: $username, email: $email, image: $image, companyName: $companyName, companyLogo: $companyLogo, createdAt: $createdAt}';
  }

  ChatUser copyWith({
    int? id,
    String? userType,
    String? username,
    String? email,
    String? image,
    String? companyName,
    String? companyLogo,
    DateTime? createdAt,
  }) {
    return ChatUser(
      id: id ?? this.id,
      userType: userType ?? this.userType,
      username: username ?? this.username,
      email: email ?? this.email,
      image: image ?? this.image,
      companyName: companyName ?? this.companyName,
      companyLogo: companyLogo ?? this.companyLogo,
      createdAt: createdAt ?? this.createdAt,
    );
  }



  static const ChatUser empty = ChatUser(
    id: 0,
    userType: '',
    username: '',
    email: '',
    image: null,
    companyName: null,
    companyLogo: null,
    createdAt: null,
  );

  @override
  List<Object> get props=> [
    id,
    userType,
    username,
    email,
    image ?? '',
    companyName ?? '',
    companyLogo ?? '',
    createdAt ?? DateTime.now(),
  ];


}

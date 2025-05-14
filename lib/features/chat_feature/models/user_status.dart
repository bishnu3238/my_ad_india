import 'package:equatable/equatable.dart';
import 'package:pack/extensions/extensions.dart';

enum UserType { customer, agent, merchant, admin, none }

class UserStatus extends Equatable {
  final UserType userType;
  final int userId;
  final bool isOnline;
  final String? socketId;
  final DateTime? lastActivity;

  const UserStatus({
    required this.userType,
    required this.userId,
    required this.isOnline,
    this.socketId,
    this.lastActivity,
  });

  factory UserStatus.fromJson(Map<String, dynamic> json) => UserStatus(
    userType: json.getEnum('userType', UserType.values, UserType.customer),
    userId: json.getInt('userId'),
    isOnline: json.getBool('isOnline'), // == true || json['isOnline'] == 1,
    socketId: json.getString('socketId'),
    lastActivity: json.getDateTime('lastActivity'), // != null
    // ? DateTime.parse(json['lastActivity'])
    // : null,
  );

  UserStatus copyWith({
    UserType? userType,
    int? userId,
    bool? isOnline,
    String? socketId,
    DateTime? lastActivity,
  }) {
    return UserStatus(
      userType: userType ?? this.userType,
      userId: userId ?? this.userId,
      isOnline: isOnline ?? this.isOnline,
      socketId: socketId ?? this.socketId,
      lastActivity: lastActivity ?? this.lastActivity,
    );
  }

  static UserStatus empty = UserStatus(
    userType: UserType.none,
    userId: 0,
    isOnline: false,
    socketId: null,
    lastActivity: null,
  );

  @override
  List<Object?> get props => [
    userType,
    userId,
    isOnline,
    socketId,
    lastActivity,
  ];
}

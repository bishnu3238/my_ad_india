// models/plan_activity_model.dart
import 'dart:developer' as dev;
import 'package:pack/pack.dart';
import 'package:equatable/equatable.dart';

class PlanActivityModel extends Equatable {
  final int id;
  final String activities;
  final String accessType;
  final String length;
  final String activityType;
  final String demo;

  const PlanActivityModel({
    required this.id,
    required this.activities,
    required this.accessType,
    required this.length,
    required this.activityType,
    required this.demo,
  });

  factory PlanActivityModel.fromJson(Map<String, dynamic> json) {
    return PlanActivityModel(
      id: json.getInt('id'),
      activities: json.getString('activities'),
      accessType: json.getString('access_type'),
      length: json.getString('length'),
      activityType: json.getString('activity_type'),
      demo: json.getString('demo'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'activities': activities,
      'access_type': accessType,
      'length': length,
      'activity_type': activityType,
      'demo': demo,
    };
  }

  @override
  List<Object?> get props => [
    id,
    activities,
    accessType,
    length,
    activityType,
    demo,
  ];

  static empty() => PlanActivityModel(
    id: 0,
    activities: '',
    accessType: '',
    length: '',
    activityType: '',
    demo: '',
  );
}

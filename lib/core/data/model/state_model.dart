import 'dart:developer' as dev;

import 'package:pack/pack.dart';
import 'package:pack/services/base_services/base_model.dart';

class StateModel extends BaseModel<StateModel> {
  final String name;

  const StateModel({required super.id, required this.name});

  factory StateModel.fromJson(Map<String, dynamic> json) {
    dev.log('${json.runtimeType}:: $json');
    return StateModel(id: json.getString('id'), name: json.getString('name'));
  }

  StateModel copyWith() {
    // TODO: implement copyWith
    throw UnimplementedError();
  }

  @override
  List<Object?> get props => [id, name];

  @override
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}

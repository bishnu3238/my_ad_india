import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pack/services/base_services/base_service.dart';

import '../../data/model/model.dart';

class StateStore extends CollectionStore<StateModel> {


  StateModel getStateById(String id) => items.firstWhere((e) => e.name == id);
}

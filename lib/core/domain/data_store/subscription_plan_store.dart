import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pack/services/base_services/base_service.dart';

import '../../data/model/model.dart';

class SubscriptionPlanStore extends CollectionStore<SubscriptionPlanModel> {



  SubscriptionPlanModel getPlanById(String id) => items.firstWhere(
    (e) => e.id.toString() == id,
    orElse: () => SubscriptionPlanModel.empty(),
  );
}

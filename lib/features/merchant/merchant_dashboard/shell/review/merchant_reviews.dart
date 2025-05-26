// Let's update the merchant_reviews.dart file to use our provider properly

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_ad/features/merchant/merchant_dashboard/shell/review/core/merchant_review_provider.dart';
import 'package:my_ad/features/merchant/merchant_dashboard/shell/review/body/customer_reviews.dart';
import 'package:pack/services/service.dart';
class MerchantReviews extends StatelessWidget {
   const MerchantReviews({super.key, });

  @override
  Widget build(BuildContext context) {


    return const Scaffold(
      body: CustomerReviews(),
    );
  }
}




// Extensions to help with JSON parsing
extension MapExtension on Map<String, dynamic> {
  String getString(String key, {String defaultValue = ''}) {
    final value = this[key];
    if (value == null) return defaultValue;
    return value.toString();
  }

  double getDouble(String key, {double defaultValue = 0.0}) {
    final value = this[key];
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (_) {
        return defaultValue;
      }
    }
    return defaultValue;
  }

  int getInt(String key, {int defaultValue = 0}) {
    final value = this[key];
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      try {
        return int.parse(value);
      } catch (_) {
        return defaultValue;
      }
    }
    return defaultValue;
  }

  bool getBool(String key, {bool defaultValue = false}) {
    final value = this[key];
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    return defaultValue;
  }
}


// import 'package:flutter/material.dart';
//
// import 'body/customer_reviews.dart';
//
// class MerchantReviews extends StatelessWidget {
//   const MerchantReviews({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(body: CustomerReviews());
//   }
// }

import 'dart:developer' as dev;

import 'package:pack/pack.dart';
import '../product/products_model.dart';

class EadProductResponse {
  final String status;
  final List<ProductModel> products;
  final int count;

  EadProductResponse({
    required this.status,
    required this.products,
    required this.count,
  });

  factory EadProductResponse.fromJson(Map<String, dynamic> json) {
    dev.log("EadProductResponse.fromJson: $json");

    return EadProductResponse(
      status: json.getString('status'),
      products:
          (json.get('data', []))
              .map(
                (item) => ProductModel.fromJson(item as Map<String, dynamic>),
              )
              .toList(),
      count: json.getInt('count'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': products.map((product) => product.toJson()).toList(),
      'count': count,
    };
  }
}

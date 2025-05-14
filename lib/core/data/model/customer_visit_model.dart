import 'package:pack/extensions/extensions.dart';

import 'customer_model.dart';

class CustomerVisit {
  final String visitId;
  final String serviceId;
  final String merchantId;
  final String customerId;
  final String contactType;
  final String message;
  final String dated;
  final String status;
  final Customer customer;

  CustomerVisit({
    required this.visitId,
    required this.serviceId,
    required this.merchantId,
    required this.customerId,
    required this.contactType,
    required this.message,
    required this.dated,
    required this.status,
    required this.customer,
  });

  factory CustomerVisit.fromJson(Map<String, dynamic> json) {
    return CustomerVisit(
      visitId: json.getString('visit_id'),
      serviceId: json.getString('service_id'),
      merchantId: json.getString('merchant_id'),
      customerId: json.getString('customer_id'),
      contactType: json.getString('contact_type'),
      message: json.getString('message'),
      dated: json.getString('dated'),
      status: json.getString('status'),
      customer: Customer.fromJson(json['customer'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'visit_id': visitId,
      'service_id': serviceId,
      'merchant_id': merchantId,
      'customer_id': customerId,
      'contact_type': contactType,
      'message': message,
      'dated': dated,
      'status': status,
      'customer': customer.toJson(),
    };
  }

  CustomerVisit copyWith({
    String? visitId,
    String? serviceId,
    String? merchantId,
    String? customerId,
    String? contactType,
    String? message,
    String? dated,
    String? status,
    Customer? customer,
  }) {
    return CustomerVisit(
      visitId: visitId ?? this.visitId,
      serviceId: serviceId ?? this.serviceId,
      merchantId: merchantId ?? this.merchantId,
      customerId: customerId ?? this.customerId,
      contactType: contactType ?? this.contactType,
      message: message ?? this.message,
      dated: dated ?? this.dated,
      status: status ?? this.status,
      customer: customer ?? this.customer,
    );
  }

  static List<CustomerVisit> fromJsonList(List<dynamic> list) {
    return list.map((e) => CustomerVisit.fromJson(e as Map<String, dynamic>)).toList();
  }
}
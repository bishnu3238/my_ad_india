class SubmitCustomerVisitPayload {
  final int serviceId;
  final int merchantId;
  final int customerId;
  final String contactType;
  final String message;
  final String? status;

  SubmitCustomerVisitPayload({
    required this.serviceId,
    required this.merchantId,
    required this.customerId,
    required this.contactType,
    required this.message,
    this.status,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = {
      'service_id': serviceId,
      'merchant_id': merchantId,
      'customer_id': customerId,
      'contact_type': contactType,
      'message': message,

    };
    if (status != null) {
      map['status'] = status;
    }
    return map;
  }
}

class UpdateCustomerVisitPayload {
  final int id;
  final String status;
  final int? merchantId;

  UpdateCustomerVisitPayload({
    required this.id,
    required this.status,
    this.merchantId,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = {
      'id': id,
      'status': status,
    };
    if (merchantId != null) {
      map['merchant_id'] = merchantId;
    }
    return map;
  }
}

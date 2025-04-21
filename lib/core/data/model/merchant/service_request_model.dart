// models/service_request_model.dart

import 'package:equatable/equatable.dart';

enum ServiceRequestStatus { pending, approved, rejected }
enum ServiceRequestType { add, update, delete }

class ServiceRequestModel extends Equatable {
  final int? id;
  final int merchantId;
  final int? serviceId; // Null for new service requests
  final ServiceRequestType requestType; // 'add', 'update', 'delete'
  final Map<String, dynamic> serviceData; // The service data being requested
  final ServiceRequestStatus status;
  final String? adminNotes;
  final DateTime requestDate;
  final DateTime? responseDate;

  const ServiceRequestModel({
    this.id,
    required this.merchantId,
    this.serviceId,
    required this.requestType,
    required this.serviceData,
    required this.status,
    this.adminNotes,
    required this.requestDate,
    this.responseDate,
  });

  ServiceRequestModel.empty()
      : id = null,
        merchantId = 0,
        serviceId = null,
        requestType = ServiceRequestType.add,
        serviceData = const {},
        status = ServiceRequestStatus.pending,
        adminNotes = null,
        requestDate = DateTime.now(),
        responseDate = null;

  factory ServiceRequestModel.fromJson(Map<String, dynamic> json) {
    return ServiceRequestModel(
      id: json['id'],
      merchantId: json['merchant_id'],
      serviceId: json['service_id'],
      requestType: json['request_type'],
      serviceData: json['service_data'],
      status: ServiceRequestStatus.values.firstWhere(
            (e) => e.toString() == 'ServiceRequestStatus.${json['status']}',
        orElse: () => ServiceRequestStatus.pending,
      ),
      adminNotes: json['admin_notes'],
      requestDate: DateTime.parse(json['request_date']),
      responseDate: json['response_date'] != null
          ? DateTime.parse(json['response_date'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'merchant_id': merchantId,
      'service_id': serviceId,
      'request_type': requestType,
      'service_data': serviceData,
      'status': status.toString().split('.').last,
      'admin_notes': adminNotes,
      'request_date': requestDate.toIso8601String(),
      'response_date': responseDate?.toIso8601String(),
    };
  }

  ServiceRequestModel copyWith({
    int? id,
    int? merchantId,
    int? serviceId,
    ServiceRequestType? requestType,
    Map<String, dynamic>? serviceData,
    ServiceRequestStatus? status,
    String? adminNotes,
    DateTime? requestDate,
    DateTime? responseDate,
  }) {
    return ServiceRequestModel(
      id: id ?? this.id,
      merchantId: merchantId ?? this.merchantId,
      serviceId: serviceId ?? this.serviceId,
      requestType: requestType ?? this.requestType,
      serviceData: serviceData ?? this.serviceData,
      status: status ?? this.status,
      adminNotes: adminNotes ?? this.adminNotes,
      requestDate: requestDate ?? this.requestDate,
      responseDate: responseDate ?? this.responseDate,
    );
  }

  @override
  List<Object?> get props => [
    id,
    merchantId,
    serviceId,
    requestType,
    serviceData,
    status,
    adminNotes,
    requestDate,
    responseDate,
  ];
}
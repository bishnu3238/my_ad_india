import 'package:pack/extensions/extensions.dart';


class CustomerVisitResponse<T> {
  final String status;
  final String message;
  final T? data;
  final int? totalCount;
  final int? limit;
  final int? offset;

  CustomerVisitResponse({
    required this.status,
    required this.message,
    this.data,
    this.totalCount,
    this.limit,
    this.offset,
  });

  // For single visit response
  factory CustomerVisitResponse.singleVisit(
      Map<String, dynamic> json,
      T Function(Map<String, dynamic>) fromJsonT,
      ) {
    return CustomerVisitResponse<T>(
      status: json.getString('status'),
      message: json.getString('message'),
      data: json['visit'] != null ? fromJsonT(json['visit']) : null,
    );
  }

  // For multiple visits response
  factory CustomerVisitResponse.multipleVisits(
      Map<String, dynamic> json,
      T Function(List<dynamic>) fromJsonT,
      ) {
    List<dynamic> visitsList = json['visits'] is List ? json['visits'] : [];
    return CustomerVisitResponse<T>(
      status: json.getString('status'),
      message: json.getString('message'),
      data: fromJsonT(visitsList),
      totalCount: json.getInt('total_count'),
      limit: json.getInt('limit'),
      offset: json.getInt('offset'),
    );
  }

  // For generic/success/error response
  factory CustomerVisitResponse.generic(Map<String, dynamic> json) {
    return CustomerVisitResponse(
      status: json.getString('status'),
      message: json.getString('message'),
      data: json.getInt('visit_id') as T?,
    );
  }
}
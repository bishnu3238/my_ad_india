import 'dart:developer' as dev;

import 'package:equatable/equatable.dart';
import 'merchant_model.dart';
import 'package:pack/pack.dart';

enum PaymentStatus { pending, complete, cancel }

enum PlanStatus { active, inActive, expired }

class MerchantSubscriptionModel extends Equatable {
  final int? subscriptionId;
  final int merchantId;
  final int planId;
  final String planName;
  final double gst;
  final double amount;
  final DateTime startDate;
  final DateTime endDate;
  final int validity;
  final String? signature;
  final String? receivedBy;
  final String? transactionId;
  final String? orderId;
  final PaymentStatus paymentStatus;
  final DateTime? paymentDate;
  final Status status;
  final String subscriptionType;
  final PlanStatus planStatus;

  // Empty constructor with defaults
  MerchantSubscriptionModel.empty()
    : subscriptionId = null,
      merchantId = 0,
      planId = 0,
      planName = '',
      gst = 0.0,
      amount = 0.0,
      startDate = DateTime.now(),
      endDate = DateTime.now(),
      validity = 0,
      signature = null,
      receivedBy = null,
      transactionId = null,
      orderId = null,
      paymentStatus = PaymentStatus.pending,
      paymentDate = null,
      status = Status.active,
      subscriptionType = 'new',
      planStatus = PlanStatus.active;

  // Main constructor
  const MerchantSubscriptionModel({
    this.subscriptionId,
    required this.merchantId,
    required this.planId,
    required this.planName,
    required this.gst,
    required this.amount,
    required this.startDate,
    required this.endDate,
    required this.validity,
    this.signature,
    this.receivedBy,
    this.transactionId,
    this.orderId,
    this.paymentStatus = PaymentStatus.pending,
    this.paymentDate,
    this.status = Status.active,
    this.subscriptionType = 'new',
    this.planStatus = PlanStatus.active,
  });
  factory MerchantSubscriptionModel.fromJson(Map<String, dynamic> json) {
    print('Parsing MerchantSubscriptionModel JSON: $json'); // Debug log
    return MerchantSubscriptionModel(
      subscriptionId: json.getInt('subscription_id'),
      merchantId: json.getInt('merchant_id'),
      planId: json.getInt('plan_id'),
      planName: json.getString('plan_name'),
      gst: json.getDouble('gst'),
      amount: json.getDouble('amount'),
      startDate: json.getDateTime('start_date'),
      endDate: json.getDateTime('end_date'),
      validity: json.getInt('validity'),
      orderId: json.getString('order_id'),
      paymentStatus: json.getEnum(
        'payment_status',
        PaymentStatus.values,
        PaymentStatus.pending,
      ),
      paymentDate: json.getDateTime('payment_date'),
      status: json.getEnum('status', Status.values, Status.active),
      subscriptionType: json.getString('subscription_type'),
      planStatus: json.getEnum(
        'plan_status',
        PlanStatus.values,
        PlanStatus.active,
      ),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'subscription_id': subscriptionId,
      'merchant_id': merchantId,
      'plan_id': planId,
      'plan_name': planName,
      'gst': gst,
      'amount': amount,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'validity': validity,
      'signature': signature,
      'received_by': receivedBy,
      'transaction_id': transactionId,
      'order_id': orderId,
      'payment_status': paymentStatus.name,
      'payment_date': paymentDate?.toIso8601String(),
      'status': status == Status.active ? 1 : 0,
      'subscription_type': subscriptionType,
      'plan_status': planStatus.name,
    };
  }

  // CopyWith method
  MerchantSubscriptionModel copyWith({
    int? subscriptionId,
    int? merchantId,
    int? planId,
    String? planName,
    double? gst,
    double? amount,
    DateTime? startDate,
    DateTime? endDate,
    int? validity,
    String? signature,
    String? receivedBy,
    String? transactionId,
    String? orderId,
    PaymentStatus? paymentStatus,
    DateTime? paymentDate,
    Status? status,
    String? subscriptionType,
    PlanStatus? planStatus,
  }) {
    return MerchantSubscriptionModel(
      subscriptionId: subscriptionId ?? this.subscriptionId,
      merchantId: merchantId ?? this.merchantId,
      planId: planId ?? this.planId,
      planName: planName ?? this.planName,
      gst: gst ?? this.gst,
      amount: amount ?? this.amount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      validity: validity ?? this.validity,
      signature: signature ?? this.signature,
      receivedBy: receivedBy ?? this.receivedBy,
      transactionId: transactionId ?? this.transactionId,
      orderId: orderId ?? this.orderId,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentDate: paymentDate ?? this.paymentDate,
      status: status ?? this.status,
      subscriptionType: subscriptionType ?? this.subscriptionType,
      planStatus: planStatus ?? this.planStatus,
    );
  }

  @override
  String toString() {
    return 'MerchantSubscriptionModel{subscriptionId: $subscriptionId, merchantId: $merchantId, planId: $planId, planName: $planName, gst: $gst, amount: $amount, startDate: $startDate, endDate: $endDate, validity: $validity, signature: $signature, receivedBy: $receivedBy, transactionId: $transactionId, orderId: $orderId, paymentStatus: $paymentStatus, paymentDate: $paymentDate, status: $status, subscriptionType: $subscriptionType, planStatus: $planStatus}';
  } // Equatable props

  @override
  List<Object?> get props => [
    subscriptionId,
    merchantId,
    planId,
    planName,
    gst,
    amount,
    startDate,
    endDate,
    validity,
    signature,
    receivedBy,
    transactionId,
    orderId,
    paymentStatus,
    paymentDate,
    status,
    subscriptionType,
    planStatus,
  ];

  // Helper methods
  bool get isActive =>
      status == Status.active && planStatus == PlanStatus.active;
  String get validityDisplay => '$validity days';
  double get totalAmount => amount + gst;

  factory MerchantSubscriptionModel.fromLocalMap(Map<String, dynamic> json) {
    dev.log('MERCHANT-SUBSCRIPTION-FROM-LOCAL-MAP $json');
    dev.log("Merchant Status = ${json['status']}");

    return MerchantSubscriptionModel(
      // Use helper or direct casting/parsing
      subscriptionId: json.getInt('subscription_id'),
      merchantId: json.getInt('merchant_id'),
      planId: json.getInt('plan_id'),
      planName: json.getString('plan_name'),
      gst: json.getDouble('gst'),
      amount: json.getDouble('amount'),
      startDate: json.getDateTime('start_date'),
      endDate: json.getDateTime('end_date'),
      validity: json.getInt('validity'),
      signature: json.getString('signature'),
      receivedBy: json.getString('received_by'),
      transactionId: json.getString('transaction_id'),
      orderId: json.getString('order_id'),
      paymentStatus: json.getEnum(
        'payment_status',
        PaymentStatus.values,
        PaymentStatus.pending,
      ),
      // Handle nullable DateTime carefully
      paymentDate: json.getDateTime('payment_date'),
      // Handle Enum mapping
      status: json.getStatus('status', Status.values, Status.inActive),
      subscriptionType: json.getString('subscription_type'),
      planStatus: json.getEnum(
        'plan_status',
        PlanStatus.values,
        PlanStatus.active,
      ),
    );
  }
}

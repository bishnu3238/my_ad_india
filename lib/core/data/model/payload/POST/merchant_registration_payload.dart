import 'dart:convert';

class MerchantRegistrationPayload {
  final String username;
  final String email;
  final String mobile;
  final String state;
  final String pinCode;
  final String password;
  final String address;
  final String gender;
  final String businessStartYear;
  final String mobileStatus;
  final String receiveOptions;
  final String businessLocation;
  final String companyName;
  final String? gstIn;
  final String? pan;
  final String? city;
  final String? companyLogo;
  final int kyc;
  final double? latitude;
  final double? longitude;
  final String planId;
  final String planName;
  final String gst;
  final String amount;
  final String startDate;
  final String endDate;
  final int validity;
  // ---- New parameters ---
  final String categoryId;
  final String? subCategoryId;
  final String serviceId;

  MerchantRegistrationPayload({
    required this.username,
    required this.email,
    required this.mobile,
    required this.state,
    required this.pinCode,
    required this.password,
    required this.address,
    required this.gender,
    required this.businessStartYear,
    required this.mobileStatus,
    required this.receiveOptions,
    required this.businessLocation,
    required this.companyName,
    this.gstIn,
    this.pan,
    this.city,
    this.companyLogo,
    this.kyc = 0,
    this.latitude,
    this.longitude,
    required this.planId,
    required this.planName,
    required this.gst,
    required this.amount,
    required this.startDate,
    required this.endDate,
    required this.validity,

    required this.categoryId,
    this.subCategoryId,
    required this.serviceId,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'mobile': mobile,
      'state': state,
      'pincode': pinCode,
      'password': password,
      'address': address,
      'gender': gender,
      'business_start_year': businessStartYear,
      'mobile_status': mobileStatus,
      'receive_options': receiveOptions,
      'business_location': businessLocation,
      'company_name': companyName,
      'gstin': gstIn,
      'pan': pan,
      'city': city,
      'company_logo': companyLogo,
      'kyc': kyc,
      'latitude': latitude,
      'longitude': longitude,
      'plan_id': planId,
      'plan_name': planName,
      'gst': gst,
      'amount': amount,
      'start_date': startDate,
      'end_date': endDate,
      'validity': validity,
      'category_id': categoryId,
      'sub_category_id': '0', //subCategoryId,
      'service_id': serviceId,
    };
  }

  String toJsonString() => jsonEncode(toJson());

  @override
  String toString() {
    return 'MerchantRegistrationRequest{username: $username, email: $email, mobile: $mobile, state: $state, pinCode: $pinCode, password: $password, address: $address, gender: $gender, businessStartYear: $businessStartYear, mobileStatus: $mobileStatus, receiveOptions: $receiveOptions, businessLocation: $businessLocation, companyName: $companyName, gstIn: $gstIn, pan: $pan, city: $city, companyLogo: $companyLogo, kyc: $kyc, latitude: $latitude, longitude: $longitude, planId: $planId, planName: $planName, gst: $gst, amount: $amount, startDate: $startDate, endDate: $endDate, validity: $validity, categoryId: $categoryId, subCategoryId: $subCategoryId, serviceId: $serviceId}';
  }
}

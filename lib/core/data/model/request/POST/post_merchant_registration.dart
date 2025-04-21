import 'dart:convert';

class PostMerchantRegistration {
  final String username;
  final String email;
  final String mobile;
  final String state;
  final String pincode;
  final String password;
  final String address;
  final String gender;
  final String businessStartYear;
  final String mobileStatus;
  final String receiveOptions;
  final String businessLocation;
  final String companyName;
  final String? gstin;
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

  PostMerchantRegistration({
    required this.username,
    required this.email,
    required this.mobile,
    required this.state,
    required this.pincode,
    required this.password,
    required this.address,
    required this.gender,
    required this.businessStartYear,
    required this.mobileStatus,
    required this.receiveOptions,
    required this.businessLocation,
    required this.companyName,
    this.gstin,
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
  });

  factory PostMerchantRegistration.fromMap(Map<String, dynamic> map) {
    return PostMerchantRegistration(
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      mobile: map['mobile'] ?? '',
      state: map['state'] ?? '',
      pincode: map['pincode'] ?? '',
      password: map['password'] ?? '',
      address: map['address'] ?? '',
      gender: map['gender'] ?? 'male',
      businessStartYear: map['business_start_year'] ?? '',
      mobileStatus: map['mobile_status'] ?? 'public',
      receiveOptions: map['receive_options'] ?? 'email',
      businessLocation: map['business_location'] ?? '',
      companyName: map['company_name'] ?? '',
      gstin: map['gstin'],
      pan: map['pan'],
      city: map['city'],
      companyLogo: map['company_logo'],
      kyc: map['kyc'] ?? 0,
      latitude: map['latitude'] != null ? double.tryParse(map['latitude'].toString()) : null,
      longitude: map['longitude'] != null ? double.tryParse(map['longitude'].toString()) : null,
      planId: map['plan_id'] ?? '',
      planName: map['plan_name'] ?? '',
      gst: map['gst'] ?? '',
      amount: map['amount'] ?? '',
      startDate: map['start_date'] ?? '',
      endDate: map['end_date'] ?? '',
      validity: map['validity'] ?? 30,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'mobile': mobile,
      'state': state,
      'pincode': pincode,
      'password': password,
      'address': address,
      'gender': gender,
      'business_start_year': businessStartYear,
      'mobile_status': mobileStatus,
      'receive_options': receiveOptions,
      'business_location': businessLocation,
      'company_name': companyName,
      'gstin': gstin,
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
    };
  }

  String toJsonString() => jsonEncode(toJson());

  @override
  String toString() {
    return 'PostMerchantRegistration(username: $username, email: $email, mobile: $mobile, state: $state, pincode: $pincode, password: $password, address: $address, gender: $gender, businessStartYear: $businessStartYear, mobileStatus: $mobileStatus, receiveOptions: $receiveOptions, businessLocation: $businessLocation, companyName: $companyName, gstin: $gstin, pan: $pan, city: $city, companyLogo: $companyLogo, kyc: $kyc, latitude: $latitude, longitude: $longitude, planId: $planId, planName: $planName, gst: $gst, amount: $amount, startDate: $startDate, endDate: $endDate, validity: $validity)';
  }
}

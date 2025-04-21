import 'dart:developer' as dev;

import 'package:equatable/equatable.dart';
 import 'package:pack/pack.dart';

enum MobileStatus { private, public }

enum NotificationStatus { chat, email }

enum Status { active, inActive }

class MerchantModel extends Equatable {
  final int? id;
  final String username;
  final String? gstin;
  final String? pan;
  final String companyName;
  final String email;
  final String mobile;
  final int state;
  final int? city;
  final String pincode;
  final String password; // Hashed password
  final String address;
  final Gender gender;
  final int businessStartYear;
  final MobileStatus mobileStatus;
  final NotificationStatus receiveOptions;
  final String businessLocation;
  final String? companyLogo;
  final int? kyc;
  final double? latitude;
  final double? longitude;
  final bool otpVerify;
  final String? otp;
  final Status status;
  final DateTime dated;
  final String addedBy;

  // Empty constructor with defaults
  MerchantModel.empty()
    : id = null,
      username = '',
      gstin = null,
      pan = null,
      companyName = '',
      email = '',
      mobile = '',
      state = 0,
      city = null,
      pincode = '',
      password = '',
      address = '',
      gender = Gender.male,
      businessStartYear = DateTime.now().year,
      mobileStatus = MobileStatus.private,
      receiveOptions = NotificationStatus.chat,
      businessLocation = '',
      companyLogo = null,
      kyc = 0,
      latitude = null,
      longitude = null,
      otpVerify = false,
      otp = null,
      status = Status.active,
      dated = DateTime.now(),
      addedBy = '';

  // Main constructor
  const MerchantModel({
    this.id,
    required this.username,
    this.gstin,
    this.pan,
    required this.companyName,
    required this.email,
    required this.mobile,
    required this.state,
    this.city,
    required this.pincode,
    required this.password,
    required this.address,
    required this.gender,
    required this.businessStartYear,
    required this.mobileStatus,
    required this.receiveOptions,
    required this.businessLocation,
    this.companyLogo,
    this.kyc = 0,
    this.latitude,
    this.longitude,
    this.otpVerify = false,
    this.otp,
    this.status = Status.active,
    required this.dated,
    required this.addedBy,
  });

  factory MerchantModel.fromJson(Map<String, dynamic> json) {
    dev.log('Parsing MerchantModel JSON: $json'); // Debug log
    return MerchantModel(
      id: json.getInt('id'), // Pass the key 'id', not json['id']
      username: json.getString('username'),
      gstin: json.getString('gstin'),
      pan: json.getString('pan'),
      companyName: json.getString('company_name'),
      email: json.getString('email'),
      mobile: json.getString('mobile'),
      state: json.getInt('state'),
      city: json.getInt('city'),
      pincode: json.getString('pincode'),
      password: json.getString('password'),
      address: json.getString('address'),
      gender: json.getEnum('gender', Gender.values, Gender.male),
      businessStartYear: json.getInt('business_start_year'),
      mobileStatus: json.getEnum(
        'mobile_status',
        MobileStatus.values,
        MobileStatus.private,
      ),
      receiveOptions: json.getEnum(
        'receive_options',
        NotificationStatus.values,
        NotificationStatus.chat,
      ),
      businessLocation: json.getString('business_location'),
      companyLogo: json.getString('company_logo'),
      kyc: json.getInt('kyc'),
      latitude: json.getDouble('latitude'),
      longitude: json.getDouble('longitude'),
      otpVerify: json.getInt('otp_verify') == 1, // Use getInt for consistency
      otp: json.getString('otp'),
      status: json.getStatus('status', Status.values, Status.active),
      dated: json.getDateTime('dated'),
      addedBy: json.getString('added_by'),
    );
  }

  // CopyWith method for immutability
  MerchantModel copyWith({
    int? id,
    String? username,
    String? gstin,
    String? pan,
    String? companyName,
    String? email,
    String? mobile,
    int? state,
    int? city,
    String? pincode,
    String? password,
    String? address,
    Gender? gender,
    int? businessStartYear,
    MobileStatus? mobileStatus,
    NotificationStatus? receiveOptions,
    String? businessLocation,
    String? companyLogo,
    int? kyc,
    double? latitude,
    double? longitude,
    bool? otpVerify,
    String? otp,
    Status? status,
    DateTime? dated,
    String? addedBy,
  }) {
    return MerchantModel(
      id: id ?? this.id,
      username: username ?? this.username,
      gstin: gstin ?? this.gstin,
      pan: pan ?? this.pan,
      companyName: companyName ?? this.companyName,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      state: state ?? this.state,
      city: city ?? this.city,
      pincode: pincode ?? this.pincode,
      password: password ?? this.password,
      address: address ?? this.address,
      gender: gender ?? this.gender,
      businessStartYear: businessStartYear ?? this.businessStartYear,
      mobileStatus: mobileStatus ?? this.mobileStatus,
      receiveOptions: receiveOptions ?? this.receiveOptions,
      businessLocation: businessLocation ?? this.businessLocation,
      companyLogo: companyLogo ?? this.companyLogo,
      kyc: kyc ?? this.kyc,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      otpVerify: otpVerify ?? this.otpVerify,
      otp: otp ?? this.otp,
      status: status ?? this.status,
      dated: dated ?? this.dated,
      addedBy: addedBy ?? this.addedBy,
    );
  }

  @override
  String toString() {
    return 'MerchantModel{id: $id, username: $username, gstin: $gstin, pan: $pan, companyName: $companyName, email: $email, mobile: $mobile, state: $state, city: $city, pincode: $pincode, password: $password, address: $address, gender: $gender, businessStartYear: $businessStartYear, mobileStatus: $mobileStatus, receiveOptions: $receiveOptions, businessLocation: $businessLocation, companyLogo: $companyLogo, kyc: $kyc, latitude: $latitude, longitude: $longitude, otpVerify: $otpVerify, otp: $otp, status: $status, dated: $dated, addedBy: $addedBy}';
  } // Equatable props

  @override
  List<Object?> get props => [
    id,
    username,
    gstin,
    pan,
    companyName,
    email,
    mobile,
    state,
    city,
    pincode,
    password,
    address,
    gender,
    businessStartYear,
    mobileStatus,
    receiveOptions,
    businessLocation,
    companyLogo,
    kyc,
    latitude,
    longitude,
    otpVerify,
    otp,
    status,
    dated,
    addedBy,
  ];

  // Helper methods
  String get fullAddress => '$address, $businessLocation, $pincode';
  bool get isActive => status == Status.active;
  bool get isKycVerified => kyc == 1;
  String get genderDisplay =>
      gender.name.substring(0, 1).toUpperCase() + gender.name.substring(1);
  String get mobileStatusDisplay =>
      mobileStatus == 'public' ? 'Public' : 'Private';

  bool get isNotEmpty => this == MerchantModel.empty();
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'gstin': gstin,
      'pan': pan,
      'company_name': companyName,
      'email': email,
      'mobile': mobile,
      'state': state,
      'city': city,
      'pincode': pincode,
      'password': password,
      'address': address,
      'gender': gender.name,
      'business_start_year': businessStartYear,
      'mobile_status': mobileStatus.name,
      'receive_options': receiveOptions.name,
      'business_location': businessLocation,
      'company_logo': companyLogo,
      'kyc': kyc,
      'latitude': latitude,
      'longitude': longitude,
      'otp_verify': otpVerify ? '1' : '0',
      'otp': otp,
      'status': status == Status.active ? '1' : '0',
      'dated': dated.toIso8601String(),
      'added_by': addedBy,
    };
  }

  static fromLocalMap(Map<String, dynamic> map) => MerchantModel(
    id: map.getInt('id'),
    username: map.getString('username'),
    companyName: map.getString('company_name'),
    email: map.getString('email'),
    mobile: map.getString('mobile'),
    state: map.getInt('state'),
    pincode: map.getString('pincode'),
    password: map.getString('password'),
    address: map.getString('address'),
    gender: map.getEnum('gender', Gender.values, Gender.male),
    businessStartYear: map.getInt('business_start_year'),
    mobileStatus: map.getEnum(
      'mobile_status',
      MobileStatus.values,
      MobileStatus.private,
    ),
    receiveOptions: map.getEnum(
      'receive_options',
      NotificationStatus.values,
      NotificationStatus.chat,
    ),
    businessLocation: map.getString('business_location'),
    dated: map.getDateTime('dated'),
    addedBy: map.getString('added_by'),
    status: map.getEnum('status', Status.values, Status.active),
    city: map.getInt('city'),
    otp: map.getString('otp'),
    companyLogo: map.getString('company_logo'),
    gstin: map.getString('gstin'),
    pan: map.getString('pan'),
    kyc: map.getInt('kyc'),
    latitude: map.getDouble('latitude'),
    longitude: map.getDouble('longitude'),
    otpVerify: map.getInt('otp_verify') == 1,
  );
}

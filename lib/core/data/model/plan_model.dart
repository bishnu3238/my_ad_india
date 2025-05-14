import 'package:pack/services/base_services/base_model.dart';
import 'package:pack/pack.dart';
import '../api/api_config.dart';

class SubscriptionPlanModel extends BaseModel<SubscriptionPlanModel> {
  final String planName;
  final String image;
  final String banner;
  final double planRate;
  final String showValidity;
  final int validity;
  final String offer;
  final String description;
  final String profileAccess;
  final int numberOfServices;
  final int status;

  // Regular constructor
  const SubscriptionPlanModel({
    required super.id,
    required this.planName,
    required this.image,
    required this.banner,
    required this.planRate,
    required this.showValidity,
    required this.validity,
    required this.offer,
    required this.description,
    required this.profileAccess,
    this.numberOfServices =0,
    this.status = 1,
  });

  // Empty constructor
  const SubscriptionPlanModel.empty()
    : planName = '',
      image = '',
      banner = '',
      planRate = 0.0,
      showValidity = '',
      validity = 0,
      offer = '',
      description = '',
      profileAccess = '',
      numberOfServices = 0,
      status = 1,
      super(id: '');

  // Create a SubscriptionPlan from a map (useful when retrieving from database)
  // Parse JSON manually
  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanModel(
      id: json.getString('id'),
      planName: json.getString('plan_name'),
      image: json.getString('image'),
      banner: json.getString('banner'),
      planRate: json.getDouble('plan_rate'),
      showValidity: json.getString('show_validity'),
      validity: json.getInt('validity'),
      offer: json.getString('offer'),
      description: json.getString('description'),
      profileAccess: json.getString('profile_access'),
      numberOfServices: json.getInt('number_of_services'),
      status: json.getInt('status'),
    );
  }
  // Convert a SubscriptionPlan instance to a Map (useful when inserting to database)
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plan_name': planName,
      'image': image,
      'banner': banner,
      'plan_rate': planRate,
      'show_validity': showValidity,
      'validity': validity,
      'offer': offer,
      'description': description,
      'profile_access': profileAccess,
      'number_of_services': numberOfServices,
      'status': status,
    };
  }

  // Clone this instance and apply changes
  SubscriptionPlanModel copyWith({
    String? id,
    String? planName,
    String? image,
    String? banner,
    double? planRate,
    String? showValidity,
    int? validity,
    String? offer,
    String? description,
    String? profileAccess,
    int? numberOfServices,
    int? status,
  }) {
    return SubscriptionPlanModel(
      id: id ?? this.id,
      planName: planName ?? this.planName,
      image: image ?? this.image,
      banner: banner ?? this.banner,
      planRate: planRate ?? this.planRate,
      showValidity: showValidity ?? this.showValidity,
      validity: validity ?? this.validity,
      offer: offer ?? this.offer,
      description: description ?? this.description,
      profileAccess: profileAccess ?? this.profileAccess,
      numberOfServices: numberOfServices ?? this.numberOfServices,
      status: status ?? this.status,
    );
  }

  bool get isValid => id.isNotEmpty && image.isNotEmpty;
  String get fullImageUrl =>
      image.startsWith('http')
          ? image
          : "${ApiConfig.baseUrl}/${ApiConfig.subscriptionPlansImgPath}/$image";
  String get fullBannerUrl =>
      banner.startsWith('http')
          ? banner
          : "${ApiConfig.baseUrl}${ApiConfig.subscriptionPlansImgPath}/$banner";

  @override
  String toString() {
    return 'SubscriptionPlanModel{id: $id, planName: $planName, image: $image, banner: $banner, planRate: $planRate, showValidity: $showValidity, validity: $validity, offer: $offer, description: $description, profileAccess: $profileAccess, numberOfServices: $numberOfServices, status: $status}';
  }

  @override
  List<Object?> get props => [
    id,
    planName,
    image,
    banner,
    planRate,
    showValidity,
    validity,
    offer,
    description,
    profileAccess,
    numberOfServices,
    status,
  ];
}

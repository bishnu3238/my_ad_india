import 'package:dartz/dartz.dart';
import 'package:my_ad/core/services/service.dart';
import 'package:pack/services/failure/src/network_failure.dart';
import '../../data/model/model.dart';
import '../../data/model/response/referral_response.dart';

class ApiCallUseCase {
  final CityService _citiesService;
  final BannerService _bannerService;
  final CategoryService _categoryService;
  final SubcategoryService _subCategoryService;
  final ServicesService _serviceService;
  final StateService _stateService;
  final MerchantAuthService merchantService;
  final SubscriptionPlanService _subscriptionPlanService;
  final ProductService _productService;
  final ReferralService _referralService;

  ApiCallUseCase(
    this._citiesService,
    this._bannerService,
    this._categoryService,
    this._subCategoryService,
    this._serviceService,
    this._stateService,
    this.merchantService,
    this._subscriptionPlanService,
    this._productService,
    this._referralService,
  );

  Future fetchCities() async {
    return _citiesService.fetchCities();
  }

  Future fetchCategories() async {
    return await _categoryService.fetchCategories();
  }

  Future fetchSubCategories() async {
    return await _subCategoryService.fetchSubCategories();
  }

  Future fetchBanners() async {
    return await _bannerService.fetchBanners();
  }

  Future<void> fetchServices() async {
    await _serviceService.fetchServices();
  }

  Future<void> fetchState() async {
    return await _stateService.fetchStates();
  }

  Future<Either<NetworkFailure, MerchantRegistrationResponse>> merchantRegistration(PostMerchantRegistration requestBody) async {
    return merchantService.registerMerchant(requestBody);
  }

  Future fetchPlans() async {
    return _subscriptionPlanService.fetchSubscriptionPlans();
  }

  Future<void> fetchEadProducts() async {
    return await _productService.fetchProducts();
  }

  Future submitReferralRequest(PostReferralRequest request) async {
    return _referralService.submitReferralRequest(request);
  }
}

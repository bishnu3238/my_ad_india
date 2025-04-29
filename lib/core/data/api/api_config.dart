class ApiConfig {
  static const String baseUrl = 'https://eazytechno.com/ead_api';

  /// TODO: if second one is not working then uncomment the first one.
  // static const String authBaseUrl = '$baseUrl/auth/auth.php';
  static const String authBaseUrl = '$baseUrl/auth/new_auth.php';
  static const String baseChatUrl = 'http://192.168.1.12:3000';
  static const String socketUrl = 'http://192.168.1.12:3000';

  static const String baseLocalUrl = 'http://192.168.1.12/ead_api';

  // ----------------- Image Paths -----------------
  static String bannersImgPath = '/ead/admin/uploads/banner';
  static String categoryImgPath = '/ead/admin/uploads/category';
  static String plansImgPath = 'ead/admin/uploads/plans';

  static String subCategoryImgPath = '/ead/admin/uploads/category';
  static String serviceImgPath = '/ead/admin/uploads/services';
  static String eadProductImgPath = '/ead/merchant/uploads/service-images';

  // ----------------- API Endpoints -----------------

  static const String cities = '/get_cities.php';
  static const String allCities = '/get_all_cities.php';

  /// Banners API - Handles all CRUD operations for banners
  ///
  /// Endpoints:
  /// GET    /banners.php                - List all active banners
  /// GET    /banners.php?id=X           - Get a specific banner by ID
  /// GET    /banners.php?status=X       - List banners by status (0 or 1)
  /// POST   /banners.php                - Create a new banner
  /// PUT    /banners.php?id=X           - Update an existing banner
  /// DELETE /banners.php?id=X           - Delete a banner by ID
  static const String banners = '/get_banners.php';

  /// Categories API - Handles all CRUD operations for categories
  ///
  /// Endpoints:
  /// GET    /categories.php              - List all active categories
  /// GET    /categories.php?id=X         - Get a specific category by ID
  /// GET    /categories.php?search=X     - Search categories by name or title
  /// POST   /categories.php              - Create a new category
  /// PUT    /categories.php?id=X         - Update an existing category
  /// DELETE /categories.php?id=X         - Delete a category by ID
  /// GET    /categories.php?status=X     - List categories by status (0 or 1)
  static const String categories = '/get_categories.php';

  /// Subcategories API - Handles all CRUD operations for subcategories
  ///
  /// Endpoints:
  /// GET    /subcategories.php                   - List all active subcategories
  /// GET    /subcategories.php?category_id=X     - List subcategories by category ID
  /// GET    /subcategories.php?id=X              - Get a specific subcategory by ID
  /// GET    /subcategories.php?search=X          - Search subcategories by name
  /// POST   /subcategories.php                   - Create a new subcategory
  /// PUT    /subcategories.php?id=X              - Update an existing subcategory
  /// DELETE /subcategories.php?id=X              - Delete a subcategory by ID
  /// GET    /subcategories.php?status=X          - List subcategories by status (0 or 1)
  static const String subCategories = '/get_subcategories.php';

  /// Get all services: GET /services.php
  /// Get service by ID: GET /services.php?id=123
  /// Get services by category: GET /services.php?category_id=5
  /// Get services by subcategory: GET /services.php?subcategory_id=10
  /// Search services: GET /services.php?search=keyword
  /// Add new service: POST /services.php with JSON body
  /// Update service: PUT /services.php with JSON body including ID
  /// Delete service: DELETE /services.php?id=123
  static const String services = '/get_services.php';

  /// Login API - Handles user authentication and token generation.
  ///
  /// Endpoints:
  /// POST   /login.php                - Authenticate a user and return a JWT.
  ///   -  **Request Body (JSON):**
  ///     ```json
  ///     {
  ///       "mobile": "string", // User's mobile number
  ///       "password": "string"  // User's password
  ///     }
  ///     ```
  static const String login = '/auth/login';
  static const String sendOtp = '/auth/send-otp';
  static const String signUp = '/auth/signup';
  static const String forgotPassword = '/auth/forgot-password';
  static const String changePassword = '/auth/change-password';
  static const String resetPassword = '/auth/reset-password';
  static const String logout = '/auth/logout';
  static const String otp = '/auth/verify-otp';

  /// TODO -------------- * [Customer] * APis -------------------

  /// Method: [POST]
  // URL: http://yourserver/register.php?action=register
  // Body: JSON with all required fields
  /// Method: [PUT]
  // URL: http://yourserver/api.php?action=update
  /// Get All Merchants
  /// Method: [GET]
  // URL: http://yourserver/api.php?action=get_all&page=1&limit=10
  // Delete Merchant
  /// Method: [DELETE]
  // URL: http://yourserver/api.php?action=delete
  // Body: {"id": 1}
  static const String register = '/merchant/register_merchant.php';

  static const String plans = '/get_ead_plans.php';

  static const String states = '/get_states.php';

  /// Access the API via:
  /// http://localhost/ead_api/api/products.php (all products)
  /// http://localhost/ead_api/api/products.php?id=1 (filter by product ID)
  /// http://localhost/ead_api/api/products.php?category_id=cat1 (filter by category)
  /// Filter params [id], [category_id],[sub_category_id], [service_id], [merchant_id]
  static const String products = '/get_ead_products.php';

  /// ------------------------ [Merchant Section] ------------------------------

  /// Merchant Login API - Handles merchant authentication and token generation.
  static const String merchantLogin = '/merchant/login.php';
  // static const String merchantOtp = '/merchant/verify_otp.php';
  static const String merchantOtp = '/merchant/otp.php';
  // static const String merchantRegister = '/merchant/register.php';
  static const String merchantRegister =
      '/merchant/merchant_registration_new.php';
  static const String merchantVerifyMobile = '/merchant/verify_mobile.php';
  static const String merchantResendOtp = '/merchant/resend_otp.php';
  static const String merchantForgotPassword = '/merchant/forgot_password.php';
  static const String merchantChangePassword = '/merchant/change_password.php';
  static const String merchantResetPassword = '/merchant/reset_password.php';
  static const String merchantLogout = '/merchant/logout.php';
  static const String merchantBusinessImageUpload =
      '/merchant/upload_merchant_company_image.php';
  static const String merchantServiceImageUpload = '/merchant/upload_image.php';

  static const String merchantDashboard = '/merchant/merchant_dashboard.php';

  /// Method: [POST] = 'action' : 'get_merchant_plan_access'
  ///               ||[merchant_id] : merchant.id.toString(),;
  ///
  /// Method: [POST] = 'action' : 'validate_service_operation';
  ///               ||'[merchant_id]': merchant.id.toString(),
  ///               ||'[operation_type]': operationType, ('add', 'update', 'delete')
  ///               ||'[service_data]': jsonEncode(service.toJson()), [MerchantServiceModel]
  /// Method: [POST] = 'action' : 'submit_service_request';
  ///               ||'[merchant_id]': merchant.id.toString(),
  ///               ||'[request_type]': requestType, ('add', 'update', 'delete')
  ///               ||'[service_data]': jsonEncode(service.toJson()), [MerchantServiceModel]
  ///               ||'[service_id]': serviceId?.toString(),
  /// Method: [POST] = 'action' : 'fetch_services';
  ///               ||'[merchant_id]': merchant.id.toString(),
  static const String merchantService = '/merchant/merchant_service.php';

  /// ----------------------- [Merchant Section End] ---------------------------

  static const String referralSubmit = '/submit_referral.php';

  static const String planMasterActivity = '/get_plan_master_activity.php';
}

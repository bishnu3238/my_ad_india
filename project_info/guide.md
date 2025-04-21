# Project Structure for Marketplace App

## Detailed Directory Layout

```
marketplace_app/
│
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_colors.dart
│   │   │   ├── app_strings.dart
│   │   │   └── app_themes.dart
│   │   │
│   │   ├── error/
│   │   │   ├── exceptions.dart
│   │   │   └── failures.dart
│   │   │
│   │   └── utils/
│   │       ├── validators.dart
│   │       └── helpers.dart
│   │
│   ├── features/
│   │   ├── authentication/
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   ├── models/
│   │   │   │   └── repositories/
│   │   │   │
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   ├── repositories/
│   │   │   │   └── usecases/
│   │   │   │
│   │   │   └── presentation/
│   │   │       ├── bloc/
│   │   │       ├── pages/
│   │   │       └── widgets/
│   │   │
│   │   ├── listings/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │
│   │   └── search/
│   │       ├── data/
│   │       ├── domain/
│   │       └── presentation/
│   │
│   ├── services/
│   │   ├── api/
│   │   │   └── api_client.dart
│   │   │
│   │   └── local_storage/
│   │       └── local_storage_service.dart
│   │
│   └── app.dart
│
├── test/
│   ├── features/
│   ├── services/
│   └── core/
│
├── assets/
│   ├── images/
│   ├── icons/
│   └── translations/
│
├── android/
├── ios/
├── web/
└── macos/
```

## Explanation of Key Directories

### `lib/core/`
- Contains app-wide constants, utilities, and core functionality
- Includes theme management, app-wide constants, and utility functions

### `lib/features/`
- Organized by feature domains (authentication, listings, search)
- Each feature follows clean architecture principles:
  - `data/`: Data sources, models, and repository implementations
  - `domain/`: Business logic, entities, use cases
  - `presentation/`: UI-related code, BLoC, pages, widgets

### `lib/services/`
- Centralized services for API calls and local storage
- Abstraction layer for external dependencies

### Project Architecture Principles
- Clean Architecture
- Feature-based modular structure
- Separation of concerns
- Dependency Injection
- Reactive programming with BLoC

## Recommended Development Workflow
1. Define entities and models
2. Implement repositories and data sources
3. Create use cases
4. Develop BLoC for state management
5. Build UI components
6. Write unit and widget tests

## Best Practices
- Use const constructors where possible
- Implement proper error handling
- Follow Flutter's widget composition guidelines
- Use ThemeData for consistent styling
- Implement internationalization
```

This comprehensive documentation provides you with:
1. A detailed README with project overview and key considerations
2. A `pubspec.yaml` with recommended dependencies
3. A suggested project structure following clean architecture principles

Would you like me to elaborate on any specific aspect of the project documentation or help you start implementing any particular feature?



//<FlutterNetworkServicePrompt>
//     <ClassName>NetworkService</ClassName>
//     <Description>
//         A robust network service class for handling HTTP requests in a Flutter app, designed to interact with a Node.js RESTful API backend. It uses dartz for functional error handling, supports multiple HTTP methods (GET, PUT, POST, DELETE), and includes logging for debugging. The service is extensible, handles JSON and XML responses, and supports file uploads via multipart requests.
//     </Description>
// 
//     <Dependencies>
//         <Package>dart:convert</Package> <!-- JSON parsing -->
//         <Package>dartz</Package> <!-- Functional Either type -->
//         <Package>http</Package> <!-- HTTP requests -->
//         <Package>package/constant/constant.dart</Package> <!-- Custom constants -->
//         <Package>network_failure.dart</Package> <!-- Custom failure class -->
//         <Package>../extension.dart</Package> <!-- Custom extensions (e.g., logging) -->
//     </Dependencies>
// 
//     <ExistingFeatures>
//         <Feature>
//             <Name>GET Requests (get)</Name>
//             <Description>
//                 Performs a GET request with optional headers, returning JSON data wrapped in Either<NetworkFailure, T>. Includes status code validation and custom error handling.
//             </Description>
//             <Implementation>
//                 <Parameters>
//                     <Param>String url</Param>
//                     <Param>Map<String, String>? headers (optional)</Param>
//                 </Parameters>
//                 <Logic>
//                     <Step>Parse URL and log it</Step>
//                     <Step>Execute HTTP GET request</Step>
//                     <Step>Log response status and body</Step>
//                     <Step>Handle status codes (400, 401, etc.)</Step>
//                     <Step>Decode JSON and extract status from response</Step>
//                     <Step>Return Right(data) or Left(NetworkFailure)</Step>
//                 </Logic>
//                 <ErrorHandling>
//                     <Step>Catch exceptions and return NetworkFailure</Step>
//                 </ErrorHandling>
//             </Implementation>
//         </Feature>
// 
//         <Feature>
//             <Name>GET Variants (get1, get2)</Name>
//             <Description>
//                 Variants of GET: get1 returns raw JSON without status extraction; get2 parses XML responses into JSON.
//             </Description>
//             <Implementation>
//                 <Parameters>
//                     <Param>String url</Param>
//                     <Param>Map<String, String>? headers (optional)</Param>
//                 </Parameters>
//                 <Logic>
//                     <Step>get1: Basic GET with JSON decoding</Step>
//                     <Step>get2: GET with XML to JSON conversion</Step>
//                 </Logic>
//             </Implementation>
//         </Feature>
// 
//         <Feature>
//             <Name>PUT Request (put)</Name>
//             <Description>
//                 Performs a PUT request, returning JSON data. Currently lacks body parameter (TODO).
//             </Description>
//             <Implementation>
//                 <Parameters>
//                     <Param>String url</Param>
//                 </Parameters>
//                 <Logic>
//                     <Step>Execute HTTP PUT request</Step>
//                     <Step>Handle status codes</Step>
//                     <Step>Return decoded JSON or failure</Step>
//                 </Logic>
//             </Implementation>
//         </Feature>
// 
//         <Feature>
//             <Name>POST Requests (post, post1)</Name>
//             <Description>
//                 Performs POST requests with body data. post validates status from response; post1 supports JSON-encoded body and custom headers.
//             </Description>
//             <Implementation>
//                 <Parameters>
//                     <Param>String url</Param>
//                     <Param>Map<String, String> body</Param>
//                     <Param>Map<String, String>? headers (optional, post1 only)</Param>
//                 </Parameters>
//                 <Logic>
//                     <Step>post: Send body as is, validate status in response</Step>
//                     <Step>post1: JSON-encode body, add headers</Step>
//                 </Logic>
//             </Implementation>
//         </Feature>
// 
//         <Feature>
//             <Name>DELETE Request (delete)</Name>
//             <Description>
//                 Performs a DELETE request, returning JSON data or failure.
//             </Description>
//             <Implementation>
//                 <Parameters>
//                     <Param>String url</Param>
//                 </Parameters>
//                 <Logic>
//                     <Step>Execute HTTP DELETE request</Step>
//                     <Step>Handle status codes</Step>
//                     <Step>Return decoded JSON or failure</Step>
//                 </Logic>
//             </Implementation>
//         </Feature>
// 
//         <Feature>
//             <Name>Custom GET Request (getRequest)</Name>
//             <Description>
//                 Uses http.Request for GET with custom headers, returning JSON data.
//             </Description>
//             <Implementation>
//                 <Parameters>
//                     <Param>String url</Param>
//                     <Param>Map<String, String> header</Param>
//                 </Parameters>
//                 <Logic>
//                     <Step>Create and configure http.Request</Step>
//                     <Step>Send request and handle response stream</Step>
//                 </Logic>
//             </Implementation>
//         </Feature>
// 
//         <Feature>
//             <Name>Multipart POST Request (postRequest)</Name>
//             <Description>
//                 Handles file uploads with form fields via multipart request.
//             </Description>
//             <Implementation>
//                 <Parameters>
//                     <Param>String uri</Param>
//                     <Param>Map<String, String> data</Param>
//                     <Param>Map<String, dynamic> images</Param>
//                 </Parameters>
//                 <Logic>
//                     <Step>Create MultipartRequest</Step>
//                     <Step>Add fields and files</Step>
//                     <Step>Send and process streamed response</Step>
//                 </Logic>
//             </Implementation>
//         </Feature>
// 
//         <Feature>
//             <Name>Status Code Handling (_handleStatusCode)</Name>
//             <Description>
//                 Maps HTTP status codes to NetworkFailure instances with custom messages.
//             </Description>
//             <Implementation>
//                 <Parameters>
//                     <Param>int code</Param>
//                     <Param>String? msg (optional)</Param>
//                 </Parameters>
//                 <Logic>
//                     <Step>Switch on status codes (400, 401, 403, 404, 500)</Step>
//                     <Step>Return NetworkFailure or null</Step>
//                 </Logic>
//             </Implementation>
//         </Feature>
//     </ExistingFeatures>
// 
//     <Improvements>
//         <Improvement>
//             <Name>Centralized Base URL</Name>
//             <Description>
//                 Move the base URL (e.g., 'http://localhost:3000/api') to a constant in constant.dart for easier configuration across environments (dev, prod).
//             </Description>
//             <Implementation>
//                 <Step>Add `static const String baseUrl = 'http://your-api.com/api';` to constant.dart</Step>
//                 <Step>Update all methods to use `Constant.baseUrl` instead of hardcoded strings</Step>
//             </Implementation>
//         </Improvement>
// 
//         <Improvement>
//             <Name>Generic Type Safety</Name>
//             <Description>
//                 Current return type T is too generic, leading to runtime errors if JSON doesn’t match expected structure. Use type constraints or data models.
//             </Description>
//             <Implementation>
//                 <Step>Introduce a generic constraint: `Future<Either<NetworkFailure, T>> get<T extends Map<String, dynamic>>`</Step>
//                 <Step>Create data models (e.g., Customer, Merchant) and parse JSON into them</Step>
//                 <Example>
//                     ```dart
//                     class Customer {
//                       final String username;
//                       Customer.fromJson(Map<String, dynamic> json) : username = json['username'];
//                     }
//                     Future<Either<NetworkFailure, Customer>> getCustomer(String url) async {
//                       final result = await get(url);
//                       return result.map((json) => Customer.fromJson(json));
//                     }
</Example> </Implementation> </Improvement> <Improvement> <Name>PUT and DELETE Body Support</Name> <Description> Add body parameters to put and delete methods, as they currently lack data submission capabilities. </Description> <Implementation> <Step>Update signatures: `put<T>(String url, Map<String, dynamic> body, [Map<String, String>? headers])`</Step> <Step>Pass body as JSON: `await http.put(uri, body: jsonEncode(body), headers: headers)`</Step> </Implementation> </Improvement> <Improvement> <Name>Timeout Handling</Name> <Description> Add timeout to prevent hanging requests, improving UX for slow networks. </Description> <Implementation> <Step>Use `timeout`: `await http.get(uri, headers: headers).timeout(Duration(seconds: 30))`</Step> <Step>Catch TimeoutException and return NetworkFailure(error: 'Request timed out')</Step> </Implementation> </Improvement> <Improvement> <Name>Consistent Logging</Name> <Description> Standardize logging format across methods for better debugging (e.g., include method name, URL, and response). </Description> <Implementation> <Step>Create a log helper: `'[GET] $url -> ${response.statusCode}: ${response.body}'.log`</Step> <Step>Apply consistently in all methods</Step> </Implementation> </Improvement> <Improvement> <Name>Remove Redundant Methods</Name> <Description> get1 and get2 are similar to get; consolidate into a single method with optional parameters (e.g., responseType: json/xml). </Description> <Implementation> <Step>Update get: `get<T>(String url, {Map<String, String>? headers, String responseType = 'json'})`</Step> <Step>Handle XML: `if (responseType == 'xml') return StaticMethods.xmlToJson(response.body)`</Step> </Implementation> </Improvement> </Improvements> <NewFeatures> <Feature> <Name>Retry Mechanism</Name> <Description> Automatically retry failed requests (e.g., 500 errors) a configurable number of times with exponential backoff. </Description> <Implementation> <Parameters> <Param>int retries = 3</Param> <Param>Duration initialDelay = Duration(seconds: 1)</Param> </Parameters> <Logic> <Step>Wrap request in a retry loop</Step> <Step>Delay retries with increasing intervals</Step> <Example> ```dart Future<Either<NetworkFailure, T>> getWithRetry<T>(String url) async { int retries = 3; for (int i = 0; i < retries; i++) { try { return await get(url); } catch (e) { if (i == retries - 1) return left(NetworkFailure(error: e.toString())); await Future.delayed(Duration(seconds: 1 << i)); } } return left(NetworkFailure(error: 'Max retries reached')); } ``` </Example> </Logic> </Implementation> </Feature> <Feature> <Name>Authentication Token Support</Name> <Description> Automatically append an auth token (e.g., JWT) to headers, fetched from local storage. </Description> <Implementation> <Dependencies> <Package>shared_preferences</Package> </Dependencies> <Logic> <Step>Fetch token: `String? token = await SharedPreferences.getInstance().getString('token')`</Step> <Step>Add to headers: `headers ??= {}; headers['Authorization'] = 'Bearer $token';`</Step> </Logic> </Implementation> </Feature> <Feature> <Name>Cancellation Support</Name> <Description> Allow cancelling in-flight requests to avoid unnecessary network calls (e.g., when navigating away). </Description> <Implementation> <Dependencies> <Package>dio</Package> <!-- Alternative HTTP client with cancellation --> </Dependencies> <Logic> <Step>Use Dio with CancelToken: `CancelToken token = CancelToken(); await dio.get(url, cancelToken: token)`</Step> <Step>Expose cancel method: `token.cancel('Request cancelled')`</Step> </Logic> </Implementation> </Feature> <Feature> <Name>Cache Responses</Name> <Description> Cache GET responses locally to reduce network calls, with configurable TTL (time-to-live). </Description> <Implementation> <Dependencies> <Package>flutter_cache_manager</Package> </Dependencies> <Logic> <Step>Check cache: `var cached = await DefaultCacheManager().getSingleFile(url)`</Step> <Step>If cached and valid, return cached data; else fetch and cache</Step> </Logic> </Implementation> </Feature> <Feature> <Name>Real-Time Support (WebSocket)</Name> <Description> Add WebSocket support for real-time features (e.g., chat updates from `chatting` table). </Description> <Implementation> <Dependencies> <Package>web_socket_channel</Package> </Dependencies> <Logic> <Step>Connect: `final channel = WebSocketChannel.connect(Uri.parse('ws://your-api.com'))`</Step> <Step>Stream data: `Stream<T> listen() => channel.stream.map((data) => jsonDecode(data))`</Step> </Logic> </Implementation> </Feature> </NewFeatures> <Architecture> <Pattern>Service</Pattern> <ErrorHandling>Functional with dartz Either</ErrorHandling> <DependencyInjection>get_it</DependencyInjection> <Logging>Custom extension (.log)</Logging> </Architecture> <Steps> <Step> <Order>1</Order> <Task>Refactor Base URL</Task> <Details>Move base URL to constants and update all methods</Details> </Step> <Step> <Order>2</Order> <Task>Enhance Type Safety</Task> <Details>Add data models and type constraints</Details> </Step> <Step> <Order>3</Order> <Task>Add Timeout and PUT/DELETE Body</Task> <Details>Implement timeout and body support</Details> </Step> <Step> <Order>4</Order> <Task>Consolidate GET Methods</Task> <Details>Merge get1/get2 into get with responseType</Details> </Step> <Step> <Order>5</Order> <Task>Add New Features</Task> <Details>Implement retry, auth, cancellation, caching as needed</Details> </Step> </Steps> </FlutterNetworkServicePrompt>
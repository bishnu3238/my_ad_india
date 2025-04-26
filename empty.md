[log] Sign up Function called here
[log] REQUEST: RequestConfig{baseUrl: https://domaina.com/ead_api/auth/new_auth.php, endpoint: /auth/signup, method: RequestMethod.post, queryParameters: null, headers: null, body: {email: , password: 123456, name: Rahul pal, phone: 8585455355}, responseFormat: ResponseFormat.json, timeout: 0:00:30.000000, requiresAuth: false, cachePolicy: CachePolicy.networkOnly, cacheKey: null, cacheDuration: 0:05:00.000000, retryEnabled: false, maxRetries: 3, onSendProgress: null, onReceiveProgress: null}
[log] AUTH PROVIDER STATE UPDATE: Instance of 'AuthLoadingState<UserModel>'
[log] [SettingsViewModel] Auth state changed: false || Invalid endpoint
I/flutter (25309): ┌───────────────────────────────────────────────────────────────────────────────
I/flutter (25309): │ 2025-04-26 14:55:25.313
I/flutter (25309): ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
I/flutter (25309): │ 🐛 REQUEST[POST] => PATH: https://domaina.com/ead_api/auth/new_auth.php/auth/signup
I/flutter (25309): └───────────────────────────────────────────────────────────────────────────────
I/flutter (25309): ┌───────────────────────────────────────────────────────────────────────────────
I/flutter (25309): │ This exception was thrown because the response has a status code of 404 and RequestOptions.validateStatus was configured to throw for this status code.
I/flutter (25309): │ The status code of 404 has the following meaning: "Client error - the request contains bad syntax or cannot be fulfilled"
I/flutter (25309): │ Read more about status codes at https://developer.mozilla.org/en-US/docs/Web/HTTP/Status
I/flutter (25309): │ In order to resolve this exception you typically have either to verify and fix your request code or you have to fix the server code.
I/flutter (25309): │
I/flutter (25309): ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
I/flutter (25309): │ #0   DioMixin.request (package:dio/src/dio_mixin.dart:364:36)
I/flutter (25309): │ #1   DioMixin.post (package:dio/src/dio_mixin.dart:108:12)
I/flutter (25309): │ #2   DioApiClient.request (package:pack/services/api_services/src/dio_api_client.dart:163:33)
I/flutter (25309): │ #3   <asynchronous suspension>
I/flutter (25309): │ #4   AuthRepositoryImpl.signup.<anonymous closure> (package:pack/auth/src/data/auth_repository_impl.dart:238:13)
I/flutter (25309): ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
I/flutter (25309): │ 2025-04-26 14:55:25.881
I/flutter (25309): ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
I/flutter (25309): │ ⛔ ERROR[404] => PATH: https://domaina.com/ead_api/auth/new_auth.php/auth/signup
I/flutter (25309): └───────────────────────────────────────────────────────────────────────────────
I/flutter (25309): ┌───────────────────────────────────────────────────────────────────────────────
I/flutter (25309): │ DioException [bad response]: This exception was thrown because the response has a status code of 404 and RequestOptions.validateStatus was configured to throw for this status code.
I/flutter (25309): │ The status code of 404 has the following meaning: "Client error - the request contains bad syntax or cannot be fulfilled"
I/flutter (25309): │ Read more about status codes at https://developer.mozilla.org/en-US/docs/Web/HTTP/Status
I/flutter (25309): │ In order to resolve this exception you typically have either to verify and fix your request code or you have to fix the server code.
I/flutter (25309): │
I/flutter (25309): ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
I/flutter (25309): │ #0   DioMixin.fetch (package:dio/src/dio_mixin.dart:523:7)
I/flutter (25309): │ #1   <asynchronous suspension>
I/flutter (25309): │ #2   DioApiClient.request (package:pack/services/api_services/src/dio_api_client.dart:163:22)
I/flutter (25309): │ #3   <asynchronous suspension>
I/flutter (25309): │ #4   AuthRepositoryImpl.signup.<anonymous closure> (package:pack/auth/src/data/auth_repository_impl.dart:238:13)
I/flutter (25309): ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
I/flutter (25309): │ 2025-04-26 14:55:25.886
I/flutter (25309): ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
I/flutter (25309): │ ⛔ Dio Error: This exception was thrown because the response has a status code of 404 and RequestOptions.validateStatus was configured to throw for this status code.
I/flutter (25309): │ ⛔ The status code of 404 has the following meaning: "Client error - the request contains bad syntax or cannot be fulfilled"
I/flutter (25309): │ ⛔ Read more about status codes at https://developer.mozilla.org/en-US/docs/Web/HTTP/Status
I/flutter (25309): │ ⛔ In order to resolve this exception you typically have either to verify and fix your request code or you have to fix the server code.
I/flutter (25309): │ ⛔ , Response: {status: error, message: Invalid endpoint}
I/flutter (25309): └───────────────────────────────────────────────────────────────────────────────
[NetworkFailure] NetworkFailure => statusCode: 404, type: NetworkErrorType.notFound, retryCount: 0, timestamp: 2025-04-26 14:55:25.889360, data: {status: error, message: Invalid endpoint}
[log] hello
[NetworkFailure] NetworkFailure => statusCode: null, type: NetworkErrorType.unknown, retryCount: 0, timestamp: 2025-04-26 14:55:25.890572, data: null
[log] AUTH PROVIDER STATE UPDATE: Instance of 'AuthErrorState<UserModel>'
[log] [SettingsViewModel] Auth state changed: false || Invalid endpoint

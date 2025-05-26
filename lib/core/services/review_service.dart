import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:my_ad/core/data/api/api_config.dart';
import 'package:pack/constant/constant.dart';
import 'package:pack/extensions/extensions.dart';
import 'package:pack/services/service.dart';
import 'package:uuid/uuid.dart';

import 'review_service.dart';

/// HTTP implementation of the ReviewService for custom API backends
class ReviewServiceImpl implements ReviewService {
  /// Base URL of the API
  final String baseUrl;

  /// Authentication token for API requests (optional)
  final String? authToken;

  /// HTTP client for making requests
  final http.Client _client;

  /// API call service for custom API calls (optional)
  final ApiCallService _apiService;

  /// UUID generator for client-side IDs
  final Uuid _uuid = const Uuid();

  /// Create a new HttpReviewService
  ///
  /// [baseUrl] - Base URL of the API (e.g., 'https://api.example.com/v1')
  /// [authToken] - Authentication token for API requests (optional)
  /// [client] - HTTP client for making requests (optional)
  ReviewServiceImpl({
    required this.baseUrl,
    ApiCallService? apiService,
    this.authToken,
    http.Client? client,
  }) : _client = client ?? http.Client(),
       _apiService = apiService ?? ApiCallService(baseUrl: baseUrl);

  /// Get the headers for API requests
  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (authToken != null) {
      headers['Authorization'] = 'Bearer $authToken';
    }

    return headers;
  }

  @override
  Future<ReviewsResult> getReviews({required String itemId}) async {
    try {
      final config = RequestConfig(
        baseUrl: baseUrl,
        endpoint: ApiConfig.getMerchantReviews,
        method: RequestMethod.get,
        queryParameters: {'merchant_id': itemId},
      );
      return await _apiService
          .request(
            config: config,
            responseConverter: (data) {
              dev.log("REVIEW DATA:  $data");
              return ReviewsResult.fromJson(data);
              // (data as List).map((e) => Review.fromJson(e)).toList();
            },
          )
          .then(
            (value) => value.fold(
              (failure) {
                return ReviewsResult.empty();
              },
              (result) {
                return result.data!;
              },
            ),
          );
    } catch (e) {
      dev.log('GET MESSAGE ERROR : $e');
      throw Exception('Failed to get reviews: $e');
    }
  }

  @override
  Future<Review?> getReviewById(String reviewId) async {
    try {
      final config = RequestConfig(
        baseUrl: baseUrl,
        endpoint: ApiConfig.getReview,
        method: RequestMethod.get,
        queryParameters: {'id': reviewId},
        requiresAuth: true,
      );
      final result = await _apiService.request<Map<String, dynamic>>(
        config: config,
        responseConverter: (data) => data as Map<String, dynamic>,
      );
      return result.fold(
        (failure) => null,
        (response) => Review.fromJson(response.data!['data']),
      );
    } catch (e) {
      throw Exception('Failed to get review: $e');
    }
  }

  @override
  Future<Review> submitReview(ReviewData review, List<dynamic>? images) async {
    final config =
        images != null && images.isNotEmpty
            ? RequestConfig.forFileUpload(
              baseUrl: baseUrl,
              endpoint: ApiConfig.submitReview,
              files: {
                for (var i = 0; i < images.length; i++)
                  'images[$i]':
                      images[i] is File ? images[i] : File(images[i].path),
              },
              fields: {
                'merchant_id': review.itemId,
                'customer_id': review.userId,
                'service_name': review.serviceName, // Add if needed
                'review_title': review.title ?? '',
                'review_content': review.content,
                'rating': review.rating.toString(),
                'user_name': review.userName,
                'user_image_url': review.userImageUrl ?? '',
                'metadata':
                    review.metadata != null ? review.metadata.toString() : '',
              },
              requiresAuth: true,
            )
            : RequestConfig(
              baseUrl: baseUrl,
              endpoint: ApiConfig.submitReview,
              method: RequestMethod.post,
              body: {
                'merchant_id': review.itemId,
                'customer_id': review.userId,
                'service_name': review.serviceName, // Add if needed
                'review_title': review.title ?? '',
                'review_content': review.content,
                'rating': review.rating,
                'user_name': review.userName,
                'user_image_url': review.userImageUrl ?? '',
                'metadata': review.metadata,
              },
              requiresAuth: true,
            );
    final result = await _apiService.request<Review>(
      config: config,
      responseConverter: (data) {
        dev.log('SUBMIT REVIEW DATA : $data');
        return Review(
          id: data['data']['id'],
          userId: review.userId,
          userName: review.userName,
          userImageUrl: review.userImageUrl,
          itemId: review.itemId,
          rating: review.rating,
          content: review.content,
          createdAt: DateTime.now().firstDayOfWeek,
        );
      },
    );
    return result.fold((failure) => throw Exception(failure.message), (
      response,
    ) {
      dev.log('RESPONSE : ${response.data}');
      return response.data ?? Review.empty;
    });
  }

  @override
  Future<Review> updateReview(
    String reviewId,
    ReviewData review,
    List<dynamic>? images,
  ) async {
    try {
      final config =
          images != null && images.isNotEmpty
              ? RequestConfig.forFileUpload(
                baseUrl: baseUrl,
                endpoint: '${ApiConfig.updateReview}?id=$reviewId',
                files: {
                  for (var i = 0; i < images.length; i++)
                    'images[$i]':
                        images[i] is File ? images[i] : File(images[i].path),
                },
                fields: {
                  'service_name': '', // Add if needed
                  'review_title': review.title ?? '',
                  'review_content': review.content,
                  'rating': review.rating.toString(),
                  'user_name': review.userName,
                  'user_image_url': review.userImageUrl ?? '',
                  'metadata':
                      review.metadata != null ? review.metadata.toString() : '',
                },
                requiresAuth: true,
              )
              : RequestConfig(
                baseUrl: baseUrl,
                endpoint: ApiConfig.updateReview,
                //'/updateReview.php?id=$reviewId',
                method: RequestMethod.put,
                queryParameters: {'id': reviewId},
                body: {
                  'service_name': '', // Add if needed
                  'review_title': review.title ?? '',
                  'review_content': review.content,
                  'rating': review.rating,
                  'user_name': review.userName,
                  'user_image_url': review.userImageUrl ?? '',
                  'metadata': review.metadata,
                },
                requiresAuth: true,
              );
      final result = await _apiService.request<Map<String, dynamic>>(
        config: config,
        responseConverter: (data) => data as Map<String, dynamic>,
      );
      return result.fold(
        (failure) => throw Exception(failure.message),
        (response) => Review.fromJson(response.data!),
      );
    } catch (e) {
      throw Exception('Failed to update review: $e');
    }
  }

  @override
  Future<bool> deleteReview(String reviewId) async {
    try {
      final config = RequestConfig(
        baseUrl: baseUrl,
        endpoint: ApiConfig.deleteReview,
        method: RequestMethod.delete,
        queryParameters: {'id': reviewId},
        requiresAuth: true,
      );
      final result = await _apiService.request<Map<String, dynamic>>(
        config: config,
        responseConverter: (data) => data as Map<String, dynamic>,
      );
      return result.fold(
        (failure) => false,
        (response) => response.data?['status'] == 'success',
      );
    } catch (e) {
      throw Exception('Failed to delete review: $e');
    }
  }

  @override
  Future<Review> respondToReview(
    String reviewId,
    ReviewResponseData response,
  ) async {
    try {
      final config = RequestConfig(
        baseUrl: baseUrl,
        endpoint: ApiConfig.respondToReview,
        method: RequestMethod.post,
        queryParameters: {'review_id': reviewId},
        body: response.toJson(),
        requiresAuth: true,
      );
      final result = await _apiService.request<Map<String, dynamic>>(
        config: config,
        responseConverter: (data) => data as Map<String, dynamic>,
      );
      return result.fold(
        (failure) => throw Exception(failure.message),
        (resp) => Review.fromJson(resp.data!),
      );
    } catch (e) {
      throw Exception('Failed to respond to review: $e');
    }
  }

  @override
  Future<bool> markReviewHelpful(String reviewId, bool isHelpful) async {
    try {
      // The PHP API only increments helpful, so ignore isHelpful param
      final config = RequestConfig(
        baseUrl: baseUrl,
        endpoint: ApiConfig.markReviewHelpful,
        method: RequestMethod.put,
        queryParameters: {'id': reviewId},
        requiresAuth: true,
      );
      final result = await _apiService.request<Map<String, dynamic>>(
        config: config,
        responseConverter: (data) {
          dev.log('message $data');
          return data as Map<String, dynamic>;
        },
      );
      return result.fold(
        (failure) => false,
        (response) => response.data?['status'] == 'success',
      );
    } catch (e) {
      throw Exception('Failed: to mark review helpful: $e');
    }
  }

  @override
  Future<RatingSummary> getItemRatingSummary(String itemId) async {
    try {
      final config = RequestConfig(
        baseUrl: baseUrl,
        endpoint: ApiConfig.getRatingSummery,
        method: RequestMethod.get,
        queryParameters: {'merchant_id': itemId},
        requiresAuth: true,
      );
      final result = await _apiService.request<Map<String, dynamic>>(
        config: config,
        responseConverter: (data) {
          dev.log("ITEM RATING SUMMERY: $data");
          return data as Map<String, dynamic>;
        },
      );
      return result.fold(
        (failure) => throw Exception(failure.message),
        (response) => RatingSummary.fromJson(response.data!['data']),
      );
    } catch (e) {
      throw Exception('Failed to get item rating summary: $e');
    }
  }

  @override
  Future<bool> hasUserReviewedItem(String itemId, String userId) async {
    try {
      final config = RequestConfig(
        baseUrl: baseUrl,
        endpoint: ApiConfig.hasUserReviewedItem,
        method: RequestMethod.get,
        queryParameters: {'merchant_id': itemId, 'customer_id': userId},
        requiresAuth: true,
      );
      final result = await _apiService.request<Map<String, dynamic>>(
        config: config,
        responseConverter: (data) {
          dev.log('has_user_reviewed_item: $data');
          return data as Map<String, dynamic>;
        },
      );
      return result.fold(
        (failure) => false,
        (response) => response.data!.getMap('data').getBool('hasReviewed'),
      );
    } catch (e) {
      throw Exception('Failed to check if user has reviewed item: $e');
    }
  }

  /// Close the HTTP client when done
  void dispose() {
    _client.close();
  }
}

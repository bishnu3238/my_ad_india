import 'package:pack/pack.dart';

class ReviewModel {
  final String id;
  final String merchantId;
  final String customerId;
  final String serviceName;
  final String reviewTitle;
  final String reviewContent;
  final double rating;
  final List<String> imageUrls;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isVerified;
  final int helpfulCount;
  final List<Response> responses;
  final Map<String, dynamic> metadata;

  ReviewModel({
    required this.id,
    required this.merchantId,
    required this.customerId,
    required this.serviceName,
    required this.reviewTitle,
    required this.reviewContent,
    required this.rating,
    required this.imageUrls,
    required this.createdAt,
    required this.updatedAt,
    required this.isVerified,
    required this.helpfulCount,
    required this.responses,
    required this.metadata,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json.getString('id'),
      merchantId: json.getString('merchant_id'),
      customerId: json.getString('customer_id'),
      serviceName: json.getString('service_name'),
      reviewTitle: json.getString('review_title'),
      reviewContent: json.getString('review_content'),
      rating: json.getDouble('rating'),
      imageUrls: json.getStringList('image_urls'),
      createdAt: json.getDateTime('created_at'),
      updatedAt: json.getDateTime('updated_at'),
      isVerified: json.getBool('is_verified'),
      helpfulCount: json.getInt('helpful_count'),
      responses:
          (json
              .get<List<dynamic>>('responses', [])
              .map((e) => Response.fromJson(Map<String, dynamic>.from(e)))
              .toList()),
      metadata: json.getMap('metadata'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'merchant_id': merchantId,
      'customer_id': customerId,
      'service_name': serviceName,
      'review_title': reviewTitle,
      'review_content': reviewContent,
      'rating': rating,
      'image_urls': imageUrls,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_verified': isVerified,
      'helpful_count': helpfulCount,
      'responses': responses.map((e) => e.toJson()).toList(),
      'metadata': metadata,
    };
  }
}

class Response {
  final String id;
  final String userId;
  final String userName;
  final String userImageUrl;
  final String content;
  final DateTime createdAt;
  final bool isOfficial;

  Response({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userImageUrl,
    required this.content,
    required this.createdAt,
    required this.isOfficial,
  });

  factory Response.fromJson(Map<String, dynamic> json) {
    return Response(
      id: json.getString('id'),
      userId: json.getString('user_id'),
      userName: json.getString('user_name'),
      userImageUrl: json.getString('user_image_url'),
      content: json.getString('content'),
      createdAt: json.getDateTime('created_at'),
      isOfficial: json.getBool('is_official'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'user_image_url': userImageUrl,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'is_official': isOfficial,
    };
  }
}

class RatingSummary {
  final String merchantId;
  final double averageRating;
  final int totalReviews;
  final Map<String, int> ratingCounts;

  RatingSummary({
    required this.merchantId,
    required this.averageRating,
    required this.totalReviews,
    required this.ratingCounts,
  });

  factory RatingSummary.fromJson(Map<String, dynamic> json) {
    return RatingSummary(
      merchantId: json.getString('merchant_id'),
      averageRating: json.getDouble('average_rating'),
      totalReviews: json.getInt('total_reviews'),
      ratingCounts: Map<String, int>.from(
        json
            .getMap('rating_counts')
            .map(
              (key, value) => MapEntry(
                key,
                value is int ? value : int.parse(value.toString()),
              ),
            ),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'merchant_id': merchantId,
      'average_rating': averageRating,
      'total_reviews': totalReviews,
      'rating_counts': ratingCounts,
    };
  }
}

class Pagination {
  final int total;
  final int page;
  final int limit;
  final int pages;

  Pagination({
    required this.total,
    required this.page,
    required this.limit,
    required this.pages,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      total: json.getInt('total'),
      page: json.getInt('page'),
      limit: json.getInt('limit'),
      pages: json.getInt('pages'),
    );
  }

  Map<String, dynamic> toJson() {
    return {'total': total, 'page': page, 'limit': limit, 'pages': pages};
  }
}

class ReviewResponse {
  final String status;
  final List<ReviewModel>? reviews;
  final Pagination? pagination;
  final String? message;

  ReviewResponse({
    required this.status,
    this.reviews,
    this.pagination,
    this.message,
  });

  factory ReviewResponse.fromJson(Map<String, dynamic> json) {
    return ReviewResponse(
      status: json.getString('status'),
      reviews:
          json
              .getMap('data')
              .get<List<dynamic>>('reviews', [])
              .map((e) => ReviewModel.fromJson(Map<String, dynamic>.from(e)))
              .toList(),
      pagination:
          json.getMap('data').containsKey('pagination')
              ? Pagination.fromJson(json.getMap('data').getMap('pagination'))
              : null,
      message: json.getString('message', ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': {
        if (reviews != null)
          'reviews': reviews!.map((e) => e.toJson()).toList(),
        if (pagination != null) 'pagination': pagination!.toJson(),
      },
      if (message != null) 'message': message,
    };
  }
}

class RatingSummaryResponse {
  final String status;
  final RatingSummary? ratingSummary;
  final String? message;

  RatingSummaryResponse({
    required this.status,
    this.ratingSummary,
    this.message,
  });

  factory RatingSummaryResponse.fromJson(Map<String, dynamic> json) {
    return RatingSummaryResponse(
      status: json.getString('status'),
      ratingSummary:
          json.getMap('data').isNotEmpty
              ? RatingSummary.fromJson(json.getMap('data'))
              : null,
      message: json.getString('message', ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': ratingSummary?.toJson(),
      if (message != null) 'message': message,
    };
  }
}

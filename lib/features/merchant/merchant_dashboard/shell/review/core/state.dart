// First, let's improve the state.dart file to support review summaries

// Updated state.dart
import 'package:pack/services/service.dart';

class MerchantReviewState {
  bool isLoading = false;
  String errorMessage = '';
  bool hasData = false;
  List<Review> _reviews = [];
  ReviewSummary summary = ReviewSummary.empty;

  MerchantReviewParams params = MerchantReviewParams.empty;

  static MerchantReviewState initial = MerchantReviewState();

  List<Review> get reviews => _reviews;

  // Helper method to calculate review summary
  void calculateSummary() {
    if (_reviews.isEmpty) {
      summary = ReviewSummary.empty;
      return;
    }

    double averageRating = 0;
    Map<int, int> ratingDistribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

    for (var review in _reviews) {
      averageRating += review.rating;
      int rating = review.rating.round();
      if (rating >= 1 && rating <= 5) {
        ratingDistribution[rating] = (ratingDistribution[rating] ?? 0) + 1;
      }
    }

    averageRating = _reviews.isNotEmpty ? averageRating / _reviews.length : 0;

    summary = ReviewSummary(
      totalReviews: _reviews.length,
      averageRating: averageRating,
      ratingDistribution: ratingDistribution,
    );
  }

  // Set reviews and calculate summary
  void setReviews(List<Review> reviews) {
    _reviews = reviews;
    hasData = reviews.isNotEmpty;
    calculateSummary();
  }

  @override
  String toString() {
    return 'MerchantReviewState{isLoading: $isLoading, errorMessage: $errorMessage, params: $params}';
  }
}

class ReviewSummary {
  final int totalReviews;
  final double averageRating;
  final Map<int, int> ratingDistribution;

  const ReviewSummary({
    required this.totalReviews,
    required this.averageRating,
    required this.ratingDistribution,
  });

  static ReviewSummary empty = ReviewSummary(
    totalReviews: 0,
    averageRating: 0,
    ratingDistribution: {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
  );
}

class MerchantReviewParams {
  final int page;
  final int limit;
  final String? sortBy;
  final int? filterRating;

  MerchantReviewParams({
    this.page = 1,
    this.limit = 10,
    this.sortBy,
    this.filterRating,
  });

  static MerchantReviewParams empty = MerchantReviewParams();

  MerchantReviewParams copyWith({
    int? page,
    int? limit,
    String? sortBy,
    int? filterRating,
  }) {
    return MerchantReviewParams(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      sortBy: sortBy ?? this.sortBy,
      filterRating: filterRating ?? this.filterRating,
    );
  }
}

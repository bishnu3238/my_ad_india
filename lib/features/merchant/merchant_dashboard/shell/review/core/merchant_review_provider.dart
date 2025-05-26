// Now, let's update the provider to handle reviews properly

// Updated merchant_review_provider.dart
import 'package:flutter/foundation.dart';
import 'package:my_ad/features/merchant/merchant_dashboard/shell/review/core/state.dart';
import 'package:pack/services/service.dart';

class MerchantReviewProvider extends ChangeNotifier {
  final String merchantId;
  final ReviewService _reviewService;

  late MerchantReviewState state;

  MerchantReviewProvider(
    this._reviewService, {
    required this.merchantId,
    MerchantReviewState? reviewState,
  }) {
    state = reviewState ?? MerchantReviewState.initial;
    _init();
  }

  Future<void> _init() async {
    await fetchReviews();
  }

  Future<void> fetchReviews() async {
    try {
      state.isLoading = true;
      notifyListeners();

      final reviews = await _reviewService.getReviews(itemId: merchantId);

      state.setReviews(reviews.reviews);
      state.errorMessage = '';
    } catch (e) {
      state.errorMessage = 'Failed to load reviews: ${e.toString()}';
      state.hasData = false;
    } finally {
      state.isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateParams(MerchantReviewParams params) async {
    state.params = params;
    await fetchReviews();
  }

  Future<void> refreshReviews() async {
    state.params = state.params.copyWith(page: 1);
    await fetchReviews();
  }

  Future<void> loadMoreReviews() async {
    if (state.isLoading) return;

    try {
      state.isLoading = true;
      notifyListeners();

      final nextPage = state.params.page + 1;
      final moreReviews = await _reviewService.getReviews(itemId: merchantId);

      if (moreReviews.reviews.isEmpty) {
        List<Review> updatedReviews = [
          ...state.reviews,
          ...moreReviews.reviews,
        ];
        state.setReviews(updatedReviews);
        state.params = state.params.copyWith(page: nextPage);
      }
    } catch (e) {
      state.errorMessage = 'Failed to load more reviews: ${e.toString()}';
    } finally {
      state.isLoading = false;
      notifyListeners();
    }
  }

  Future<void> filterByRating(int? rating) async {
    state.params = state.params.copyWith(page: 1, filterRating: rating);
    await fetchReviews();
  }

  Future<void> sortReviews(String sortBy) async {
    state.params = state.params.copyWith(page: 1, sortBy: sortBy);
    await fetchReviews();
  }
}

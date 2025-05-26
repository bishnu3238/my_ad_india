// Updated customer_reviews.dart
import 'package:flutter/material.dart';
import 'package:pack/services/service.dart';
import 'package:provider/provider.dart';
import 'package:my_ad/features/merchant/merchant_dashboard/shell/review/core/merchant_review_provider.dart';
import 'package:my_ad/features/merchant/merchant_dashboard/shell/review/core/state.dart';
import 'package:intl/intl.dart';

class CustomerReviews extends StatefulWidget {
  const CustomerReviews({Key? key}) : super(key: key);

  @override
  State<CustomerReviews> createState() => _CustomerReviewsState();
}

class _CustomerReviewsState extends State<CustomerReviews> {
  late MerchantReviewProvider _provider;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _provider = context.read<MerchantReviewProvider>();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _provider.loadMoreReviews();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Reviews'),
        elevation: 0,
      ),
      body: Consumer<MerchantReviewProvider>(
        builder: (context, provider, _) {
          if (provider.state.isLoading && provider.state.reviews.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.state.errorMessage.isNotEmpty && !provider.state.hasData) {
            return ErrorView(
              message: provider.state.errorMessage,
              onRetry: () => provider.refreshReviews(),
            );
          }

          if (!provider.state.hasData) {
            return EmptyReviewsView(onRefresh: () => provider.refreshReviews());
          }

          return RefreshIndicator(
            onRefresh: () async => await provider.refreshReviews(),
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: ReviewSummaryWidget(summary: provider.state.summary),
                ),
                SliverToBoxAdapter(
                  child: FilterSortBar(
                    onSortChanged: (sortBy) => provider.sortReviews(sortBy),
                    onFilterChanged: (rating) => provider.filterByRating(rating),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      if (index < provider.state.reviews.length) {
                        return ReviewCard(review: provider.state.reviews[index]);
                      } else if (provider.state.isLoading) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      } else {
                        return const SizedBox();
                      }
                    },
                    childCount: provider.state.reviews.length + (provider.state.isLoading ? 1 : 0),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ReviewSummaryWidget extends StatelessWidget {
  final ReviewSummary summary;

  const ReviewSummaryWidget({Key? key, required this.summary}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    summary.averageRating.toStringAsFixed(1),
                    style: textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < summary.averageRating.floor()
                            ? Icons.star
                            : index < summary.averageRating
                            ? Icons.star_half
                            : Icons.star_border,
                        color: Colors.amber,
                        size: 18,
                      );
                    }),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${summary.totalReviews} ${summary.totalReviews == 1 ? 'review' : 'reviews'}',
                    style: textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(width: 32),
              Expanded(
                child: Column(
                  children: [5, 4, 3, 2, 1].map((rating) {
                    final count = summary.ratingDistribution[rating] ?? 0;
                    final percent = summary.totalReviews > 0
                        ? count / summary.totalReviews
                        : 0.0;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Row(
                        children: [
                          Text(
                            '$rating',
                            style: textTheme.bodySmall,
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: percent,
                                backgroundColor: Colors.grey.shade200,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _getColorForRating(rating),
                                ),
                                minHeight: 8,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 30,
                            child: Text(
                              count.toString(),
                              style: textTheme.bodySmall,
                              textAlign: TextAlign.end,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getColorForRating(int rating) {
    switch (rating) {
      case 5: return Colors.green;
      case 4: return Colors.lightGreen;
      case 3: return Colors.amber;
      case 2: return Colors.orange;
      case 1: return Colors.red;
      default: return Colors.grey;
    }
  }
}

class FilterSortBar extends StatefulWidget {
  final Function(String) onSortChanged;
  final Function(int?) onFilterChanged;

  const FilterSortBar({
    Key? key,
    required this.onSortChanged,
    required this.onFilterChanged,
  }) : super(key: key);

  @override
  State<FilterSortBar> createState() => _FilterSortBarState();
}

class _FilterSortBarState extends State<FilterSortBar> {
  String _currentSort = 'newest';
  int? _currentRatingFilter;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filters',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (_currentRatingFilter != null)
                TextButton(
                  onPressed: () {
                    setState(() => _currentRatingFilter = null);
                    widget.onFilterChanged(null);
                  },
                  child: const Text('Clear filters'),
                ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildSortDropdown(),
                const SizedBox(width: 8),
                ...List.generate(5, (index) {
                  final rating = 5 - index;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Row(
                        children: [
                          Text('$rating'),
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                        ],
                      ),
                      selected: _currentRatingFilter == rating,
                      onSelected: (selected) {
                        setState(() {
                          _currentRatingFilter = selected ? rating : null;
                        });
                        widget.onFilterChanged(_currentRatingFilter);
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildSortDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: _currentSort,
        icon: const Icon(Icons.keyboard_arrow_down),
        underline: const SizedBox(),
        isDense: true,
        items: [
          DropdownMenuItem(value: 'newest', child: Text('Newest first')),
          DropdownMenuItem(value: 'oldest', child: Text('Oldest first')),
          DropdownMenuItem(value: 'highest', child: Text('Highest rating')),
          DropdownMenuItem(value: 'lowest', child: Text('Lowest rating')),
        ],
        onChanged: (value) {
          if (value != null) {
            setState(() => _currentSort = value);
            widget.onSortChanged(value);
          }
        },
      ),
    );
  }
}

class ReviewCard extends StatelessWidget {
  final Review review;

  const ReviewCard({Key? key, required this.review}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final dateFormat = DateFormat('MMM d, yyyy');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage(review.userImageUrl),
                  backgroundColor: Colors.grey.shade200,
                  onBackgroundImageError: (_, __) {},
                  child: review.userImageUrl.isEmpty
                      ? Text(
                    review.userName.isNotEmpty
                        ? review.userName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(fontSize: 20),
                  )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              review.userName,
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (review.isVerified)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.green.shade200),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.verified,
                                    size: 14,
                                    color: Colors.green.shade700,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Verified',
                                    style: textTheme.bodySmall?.copyWith(
                                      color: Colors.green.shade700,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          ...List.generate(
                            5,
                                (index) => Icon(
                              index < review.rating ? Icons.star : Icons.star_border,
                              size: 16,
                              color: Colors.amber,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            dateFormat.format(review.createdAt),
                            style: textTheme.bodySmall?.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (review.title != null && review.title!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                review.title!,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(review.content),
            if (review.imageUrls.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: review.imageUrls.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          review.imageUrls[index],
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.error),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
            if (review.responses.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              ...review.responses.map((response) {
                return Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: _ResponseWidget(response: response),
                );
              }),
            ],
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.thumb_up_outlined,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${review.helpfulCount} helpful',
                      style: textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.reply, size: 16),
                  label: const Text('Reply'),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ResponseWidget extends StatelessWidget {
  final ReviewResponse response;

  const _ResponseWidget({Key? key, required this.response}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final dateFormat = DateFormat('MMM d, yyyy');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: response.isOfficial ? Colors.blue.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: response.isOfficial ? Colors.blue.shade100 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage: response.userImageUrl != null
                    ? NetworkImage(response.userImageUrl!)
                    : null,
                backgroundColor: response.isOfficial
                    ? Colors.blue.shade200
                    : Colors.grey.shade300,
                child: response.userImageUrl == null
                    ? Text(
                  response.userName.isNotEmpty
                      ? response.userName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(fontSize: 14),
                )
                    : null,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          response.userName,
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (response.isOfficial) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Official',
                              style: textTheme.bodySmall?.copyWith(
                                color: Colors.blue.shade800,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      dateFormat.format(response.createdAt),
                      style: textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            response.content,
            style: textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class EmptyReviewsView extends StatelessWidget {
  final VoidCallback onRefresh;

  const EmptyReviewsView({Key? key, required this.onRefresh}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.rate_review_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No Reviews Yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'When customers leave reviews, they will appear here.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onRefresh,
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }
}

class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorView({Key? key, required this.message, required this.onRetry})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
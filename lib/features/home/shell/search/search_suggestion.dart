import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:pack/services/search_service/search_utility.dart';

import '../../../../core/data/model/product/category_model.dart';

// SearchSuggestionView widget for displaying search suggestions
class SearchSuggestionView extends StatelessWidget {
  final List<Searchable> suggestions;
  final Function(Searchable) onSuggestionTap;
  final bool isLoading;
  final String query;
  final Widget? recommendedSuggestions;

  const SearchSuggestionView({
    super.key,
    required this.suggestions,
    required this.onSuggestionTap,
    required this.isLoading,
    required this.query,
    this.recommendedSuggestions,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingView();
    }

    if (suggestions.isEmpty && query.isEmpty) {
      return _buildInitialSuggestionsView(context);
    }

    if (suggestions.isEmpty) {
      return _buildEmptyResultView();
    }

    return _buildSuggestionsView(context);
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: CupertinoActivityIndicator(),
      ),
    );
  }

  Widget _buildInitialSuggestionsView(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (recommendedSuggestions != null) recommendedSuggestions!,
        _buildRecentSearchesSection(context),
      ],
    );
  }

  Widget _buildRecentSearchesSection(BuildContext context) {
    final recentSearches = context.select<SearchProvider, List<String>>(
      (provider) => provider.recentSearches,
    );

    if (recentSearches.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Searches',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  context.read<SearchProvider>().clearRecentSearches();
                },
                child: Text(
                  'Clear',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        Wrap(
          spacing: 8,
          children:
              recentSearches
                  .map(
                    (term) => RecentSearchChip(
                      term: term,
                      onTap: () {
                        // context.read<SearchProvider>().search(term);
                      },
                    ),
                  )
                  .toList(),
        ),
      ],
    );
  }

  Widget _buildEmptyResultView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          Icon(Icons.search_off_rounded, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No results found for "$query"',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try different keywords or check for typos',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsView(BuildContext context) {
    // Group suggestions by type
    final Map<SearchResultType, List<Searchable>> groupedSuggestions = {};

    for (var suggestion in suggestions) {
      groupedSuggestions.putIfAbsent(suggestion.resultType, () => []);
      groupedSuggestions[suggestion.resultType]!.add(suggestion);
    }

    return ListView(
      padding: const EdgeInsets.only(top: 8),
      children:
          groupedSuggestions.entries.map((entry) {
            return _buildSuggestionSection(context, entry.key, entry.value);
          }).toList(),
    );
  }

  Widget _buildSuggestionSection(
    BuildContext context,
    SearchResultType type,
    List<Searchable> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            _getSectionTitle(type),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        ...items.map(
          (item) =>
              SuggestionItem(item: item, query: query, onTap: onSuggestionTap),
        ),
        const Divider(height: 1),
      ],
    );
  }

  String _getSectionTitle(SearchResultType type) {
    switch (type) {
      case SearchResultType.category:
        return 'Categories';
      case SearchResultType.subCategory:
        return 'Sub Categories';
      case SearchResultType.service:
        return 'Services';
      case SearchResultType.merchant:
        return 'Merchants';
      case SearchResultType.eadProduct:
        return 'Products';
    }
  }
}

class RecentSearchChip extends StatelessWidget {
  final String term;
  final VoidCallback onTap;

  const RecentSearchChip({super.key, required this.term, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        margin: const EdgeInsets.only(left: 8, bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.history,
              size: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              term,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SuggestionItem extends StatelessWidget {
  final Searchable item;
  final String query;
  final Function(Searchable) onTap;

  const SuggestionItem({
    Key? key,
    required this.item,
    required this.query,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(item),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            _buildLeadingIcon(context),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HighlightedText(
                    text: item.displayName,
                    highlight: query,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    highlightStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  if (item.displayDescription.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    HighlightedText(
                      text: item.displayDescription,
                      highlight: query,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                      highlightStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _buildLeadingIcon(BuildContext context) {
    // Try to use the actual image if it's a CategoryModel with imageUrl
    if (item is CategoryModel && (item as CategoryModel).searchImageUrl.isNotEmpty) {
      return _buildCategoryIcon(context);
    }

    // Default icons based on result type
    IconData iconData;
    Color iconColor;

    switch (item.resultType) {
      case SearchResultType.category:
        iconData = Icons.category_rounded;
        iconColor = Colors.orange;
        break;
      case SearchResultType.subCategory:
        iconData = Icons.subdirectory_arrow_right_rounded;
        iconColor = Colors.green;
        break;
      case SearchResultType.service:
        iconData = Icons.miscellaneous_services_rounded;
        iconColor = Colors.blue;
        break;
      case SearchResultType.merchant:
        iconData = Icons.store_rounded;
        iconColor = Colors.purple;
        break;
      case SearchResultType.eadProduct:
        iconData = Icons.shopping_bag_rounded;
        iconColor = Colors.red;
        break;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(iconData, color: iconColor),
    );
  }

  Widget _buildCategoryIcon(BuildContext context) {
    final category = item as CategoryModel;
    final imageUrl = category.fullImageUrl;

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.category_rounded, color: Colors.orange.shade300);
          },
        ),
      ),
    );
  }
}

class HighlightedText extends StatelessWidget {
  final String text;
  final String highlight;
  final TextStyle style;
  final TextStyle highlightStyle;

  const HighlightedText({
    Key? key,
    required this.text,
    required this.highlight,
    required this.style,
    required this.highlightStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (highlight.isEmpty) {
      return Text(text, style: style);
    }

    final List<InlineSpan> spans = [];
    final String lowerText = text.toLowerCase();
    final String lowerHighlight = highlight.toLowerCase();

    int start = 0;
    int indexOfHighlight;

    do {
      indexOfHighlight = lowerText.indexOf(lowerHighlight, start);
      if (indexOfHighlight < 0) {
        // No more matches, add the rest of the text
        if (start < text.length) {
          spans.add(TextSpan(text: text.substring(start), style: style));
        }
        break;
      }

      // Add text before the highlight
      if (indexOfHighlight > start) {
        spans.add(
          TextSpan(text: text.substring(start, indexOfHighlight), style: style),
        );
      }

      // Add the highlighted text (using original case)
      spans.add(
        TextSpan(
          text: text.substring(
            indexOfHighlight,
            indexOfHighlight + highlight.length,
          ),
          style: highlightStyle,
        ),
      );

      // Move start to after the highlight
      start = indexOfHighlight + highlight.length;
    } while (true);

    return RichText(text: TextSpan(children: spans));
  }
}

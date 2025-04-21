import 'package:flutter/material.dart';
import '../core/ead_product_view_model.dart';

class FilterBottomSheet extends StatefulWidget {
  final EadProductsViewModel viewModel;
  final ThemeData theme;

  const FilterBottomSheet({
    super.key,
    required this.viewModel,
    required this.theme,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  double _distanceValue = 15;
  RangeValues _priceRangeValues = const RangeValues(1000, 30000);
  String _selectedSortOption = 'Recommended';
  bool _onlyVerifiedMerchants = true;
  bool _specialOffers = true;
  bool _availableNow = false;
  final List<String> _selectedLocations = ['Kolkata'];
  final List<String> _selectedCategories = ['Sewing Machine'];
  final List<String> _selectedRatings = ['4★ & above'];

  @override
  void initState() {
    super.initState();
    // Initialize filter values from viewModel state if available
    _selectedSortOption = widget.viewModel.selectedSortOption;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildSortOptions(),
                  const Divider(),
                  _buildPriceRangeFilter(),
                  const Divider(),
                  _buildDistanceFilter(),
                  const Divider(),
                  _buildCategoryFilter(),
                  const Divider(),
                  _buildLocationFilter(),
                  const Divider(),
                  _buildRatingFilter(),
                  const Divider(),
                  _buildAdditionalFilters(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            _buildActionButtons(),
          ],
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            'Filter Products',
            style: widget.theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSortOptions() {
    const sortOptions = [
      'Recommended',
      'Newest',
      'Price: Low to High',
      'Price: High to Low',
      'Nearby',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Sort By',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        Wrap(
          spacing: 8,
          children: sortOptions.map((option) {
            final isSelected = _selectedSortOption == option;
            return FilterChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedSortOption = option;
                });
              },
              backgroundColor: widget.theme.colorScheme.surfaceContainerHighest,
              selectedColor: widget.theme.colorScheme.primaryContainer,
              labelStyle: TextStyle(
                color: isSelected
                    ? widget.theme.colorScheme.primary
                    : widget.theme.colorScheme.onSurfaceVariant,
              ),
              checkmarkColor: widget.theme.colorScheme.primary,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPriceRangeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Price Range',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '₹${_priceRangeValues.start.toInt()}',
              style: TextStyle(
                color: widget.theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '₹${_priceRangeValues.end.toInt()}',
              style: TextStyle(
                color: widget.theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        RangeSlider(
          values: _priceRangeValues,
          min: 0,
          max: 50000,
          divisions: 50,
          activeColor: widget.theme.colorScheme.primary,
          inactiveColor: widget.theme.colorScheme.primaryContainer,
          labels: RangeLabels(
            '₹${_priceRangeValues.start.toInt()}',
            '₹${_priceRangeValues.end.toInt()}',
          ),
          onChanged: (RangeValues values) {
            setState(() {
              _priceRangeValues = values;
            });
          },
        ),
      ],
    );
  }

  Widget _buildDistanceFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              const Text(
                'Distance',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Spacer(),
              Text(
                '${_distanceValue.toInt()} km',
                style: TextStyle(
                  color: widget.theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Slider(
          value: _distanceValue,
          min: 1,
          max: 50,
          divisions: 49,
          activeColor: widget.theme.colorScheme.primary,
          inactiveColor: widget.theme.colorScheme.primaryContainer,
          label: '${_distanceValue.toInt()} km',
          onChanged: (double value) {
            setState(() {
              _distanceValue = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildCategoryFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Categories',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        Wrap(
          spacing: 8,
          children: [
            'All Categories',
            'Sewing Machine',
            'Electronic Items',
            'Furniture',
            'Tools',
            'Appliances',
          ].map((category) {
            final isSelected = _selectedCategories.contains(category);
            return FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedCategories.add(category);
                  } else {
                    _selectedCategories.remove(category);
                  }
                });
              },
              backgroundColor: widget.theme.colorScheme.surfaceContainerHighest,
              selectedColor: widget.theme.colorScheme.primaryContainer,
              labelStyle: TextStyle(
                color: isSelected
                    ? widget.theme.colorScheme.primary
                    : widget.theme.colorScheme.onSurfaceVariant,
              ),
              checkmarkColor: widget.theme.colorScheme.primary,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLocationFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Locations',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        Wrap(
          spacing: 8,
          children: [
            'Kolkata',
            'Delhi',
            'Mumbai',
            'Chennai',
            'Bangalore',
            'Hyderabad',
          ].map((location) {
            final isSelected = _selectedLocations.contains(location);
            return FilterChip(
              label: Text(location),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedLocations.add(location);
                  } else {
                    _selectedLocations.remove(location);
                  }
                });
              },
              backgroundColor: widget.theme.colorScheme.surfaceContainerHighest,
              selectedColor: widget.theme.colorScheme.primaryContainer,
              labelStyle: TextStyle(
                color: isSelected
                    ? widget.theme.colorScheme.primary
                    : widget.theme.colorScheme.onSurfaceVariant,
              ),
              checkmarkColor: widget.theme.colorScheme.primary,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRatingFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Ratings',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        Wrap(
          spacing: 8,
          children: [
            '4★ & above',
            '3★ & above',
            '2★ & above',
            'All ratings',
          ].map((rating) {
            final isSelected = _selectedRatings.contains(rating);
            return FilterChip(
              label: Text(rating),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedRatings.clear(); // Single selection
                    _selectedRatings.add(rating);
                  }
                });
              },
              backgroundColor: widget.theme.colorScheme.surfaceContainerHighest,
              selectedColor: widget.theme.colorScheme.primaryContainer,
              labelStyle: TextStyle(
                color: isSelected
                    ? widget.theme.colorScheme.primary
                    : widget.theme.colorScheme.onSurfaceVariant,
              ),
              checkmarkColor: widget.theme.colorScheme.primary,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAdditionalFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Additional Filters',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        SwitchListTile(
          title: const Text('Only Verified Merchants'),
          value: _onlyVerifiedMerchants,
          onChanged: (value) {
            setState(() {
              _onlyVerifiedMerchants = value;
            });
          },
          activeColor: widget.theme.colorScheme.primary,
        ),
        SwitchListTile(
          title: const Text('Special Offers'),
          value: _specialOffers,
          onChanged: (value) {
            setState(() {
              _specialOffers = value;
            });
          },
          activeColor: widget.theme.colorScheme.primary,
        ),
        SwitchListTile(
          title: const Text('Available Now'),
          value: _availableNow,
          onChanged: (value) {
            setState(() {
              _availableNow = value;
            });
          },
          activeColor: widget.theme.colorScheme.primary,
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  // Reset all filters to default values
                  _distanceValue = 15;
                  _priceRangeValues = const RangeValues(1000, 30000);
                  _selectedSortOption = 'Recommended';
                  _onlyVerifiedMerchants = true;
                  _specialOffers = true;
                  _availableNow = false;
                  _selectedLocations.clear();
                  _selectedLocations.add('Kolkata');
                  _selectedCategories.clear();
                  _selectedCategories.add('Sewing Machine');
                  _selectedRatings.clear();
                  _selectedRatings.add('4★ & above');
                });
              },
              child: const Text('Reset'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FilledButton(
              onPressed: () {
                // Apply all filters
                widget.viewModel.setSortOption(_selectedSortOption);
                widget.viewModel.applyPriceRangeFilter(
                  _priceRangeValues.start,
                  _priceRangeValues.end,
                );
                widget.viewModel.applyDistanceFilter(_distanceValue);

                // Close the bottom sheet
                Navigator.pop(context);
              },
              child: const Text('Apply'),
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'body/location_app_bar.dart';
import 'body/other_cities_list.dart';
import '../../core/domain/data_store/cities_store.dart';
import '../../core/injector/dependency_injection.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../core/data/model/city_model.dart';
import '../../provider_state/location_provider.dart';
import 'body/auto_detection_button.dart';
import 'body/location_search_bar.dart';
import 'body/popular_cities_grid.dart';
import 'core/location_view_model.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  late LocationScreenProvider locationViewModel;
  final TextEditingController _searchController = TextEditingController();

  List<CityModel> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();

    locationViewModel = DependencyInjector.get<LocationScreenProvider>();

    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // Handle search text changes
  void _onSearchChanged() {
    final query = _searchController.text.trim();
    setState(() {
      _isSearching = query.isNotEmpty;
      _searchResults = locationViewModel.search(query);
      // _searchResults = filterCities(query);
    });
  }

  // Build the search results list
  Widget _buildSearchResults() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _searchResults.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final city = _searchResults[index];
        return ListTile(
          title: Text(city.name),
          onTap: () => _selectCity(city.name),
        );
      },
    );
  }

  // Select a city and navigate back
  void _selectCity(String cityName) {
    final provider = Provider.of<LocationProvider>(context, listen: false);
    provider.setCity(cityName);
    context.pop(); // Go back to previous screen
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context);

    return ChangeNotifierProvider.value(
      value: locationViewModel,
      child: Scaffold(
        appBar: LocationAppBar(),
        body: Consumer<LocationScreenProvider>(
          builder: (context, viewModel, child) {
            return GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Column(
                children: [
                  buildSearchBar(_searchController),
                  AutoDetectionButton(),

                  // Show error message if there is one
                  if (locationProvider.error != null)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        locationProvider.error!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.justify,
                        maxLines: 3,
                      ),
                    ),

                  Expanded(
                    child: ListView(
                      children: [
                        // Show search results if searching, otherwise show popular and other cities
                        if (_isSearching)
                          _buildSearchResults()
                        else ...[
                          PopularCitiesGrid(),
                          OtherCitiesList(),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

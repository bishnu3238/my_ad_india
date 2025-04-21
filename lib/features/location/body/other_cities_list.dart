import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../provider_state/location_provider.dart';
import '../core/location_view_model.dart';

class OtherCitiesList extends StatefulWidget {
  const OtherCitiesList({super.key});

  @override
  State<OtherCitiesList> createState() => _OtherCitiesListState();
}

class _OtherCitiesListState extends State<OtherCitiesList>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context);

    return Consumer<LocationScreenProvider>(
      builder: (context, locationViewModel, child) {
        final otherCities = locationViewModel.getOtherCities;
        return AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'OTHER CITIES',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount:
                        otherCities.length >= 20 ? 20 : otherCities.length,
                    // separatorBuilder:
                    //     (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final city = otherCities[index];
                      final isSelected =
                          city.name == locationProvider.currentLocation;

                      return ListTile(
                        title: Text(
                          city.name,
                          style: TextStyle(
                            fontWeight:
                                isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                          ),
                        ),
                        // onTap: () => _selectCity(city.name),
                        trailing:
                            isSelected
                                ? const Icon(Icons.check, color: Colors.green)
                                : null,
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

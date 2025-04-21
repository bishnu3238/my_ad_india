import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../provider_state/location_provider.dart';
import '../core/location_view_model.dart';

class PopularCitiesGrid extends StatefulWidget {
  const PopularCitiesGrid({super.key});

  @override
  State<PopularCitiesGrid> createState() => _PopularCitiesGridState();
}

class _PopularCitiesGridState extends State<PopularCitiesGrid> with SingleTickerProviderStateMixin {

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;



  @override
  void initState() {
    super.initState();

    // Setup animation controller for fade-in effect
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    // Start animation when screen loads
    _animationController.forward();

    // Add listener to search controller
   }

  @override
  void dispose() {
     _animationController.dispose();
    super.dispose();
  }

  // Select a city and navigate back
  void _selectCity(String cityName) {
    final provider = Provider.of<LocationProvider>(context, listen: false);
    provider.setCity(cityName);
    context.pop(); // Go back to previous screen
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<LocationScreenProvider>(
      builder: (context, viewModel, child) {

        final popularCities = viewModel.popularCities;
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
                      'POPULAR CITIES',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    color: Colors.blue[50],
                    padding: const EdgeInsets.all(16.0),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 15.0,
                            mainAxisSpacing: 15.0,
                          ),
                      itemCount: popularCities.length,
                      itemBuilder: (context, index) {
                        final city = popularCities[index];
                        return GestureDetector(
                          onTap: () => _selectCity(city.name),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 25,
                                backgroundColor: Colors.blue[100],
                                child: Icon(
                                  city.icon ?? Icons.location_city,
                                  color: Colors.blue[800],
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                city.name,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
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

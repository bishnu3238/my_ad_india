class FetchNearByProductsOfUserPayload {
  final double latitude;
  final double longitude;
  final int radius;
  final String city;

  FetchNearByProductsOfUserPayload({
    required this.latitude,
    required this.longitude,
    required this.radius,
    required this.city,
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
      'city': city,
    };
  }

  @override
  String toString() {
    return 'FetchNearByProductsOfUserPayload{latitude: $latitude, longitude: $longitude, radius: $radius, city: $city}';
  }
}
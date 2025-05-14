import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';
import 'package:pack/constant/duration.dart';
 import 'package:pack/services/service.dart';
import '../../domain/data_store/cities_store.dart';
 import '../../domain/repository/cities_repository.dart';
import '../api/api_config.dart';
import '../model/city_model.dart';

class CitiesRepositoryImpl implements CitiesRepository {
  final ApiCallService _apiService;
  final CitiesStore _citiesStore;

  // In-memory cache
  List<CityModel>? _cachedCities;

  CitiesRepositoryImpl(this._apiService, this._citiesStore);

  @override
  Future<Either<NetworkFailure, List<CityModel>>> fetchCities() async {
    try {
      return _apiService
          .request<List<CityModel>>(
            config: RequestConfig(
              baseUrl: ApiConfig.baseUrl,
              endpoint: ApiConfig.getAllCitiesEndPoint,
              method: RequestMethod.get,
              responseFormat: ResponseFormat.json,
            ),
            responseConverter: _convertCity,
          )
          .then(
            (result) => result.fold((failure) => left(failure), (response) {
              if (response.data == null) {
                return left(NetworkFailure(message: 'Failed to fetch cities'));
              } else {
                _citiesStore.setItems(response.data!);
                _cachedCities = response.data!;
                return right(response.data!);
              }
            }),
          );
    } catch (e, stack) {
      return left(
        NetworkFailure(
          message: 'Failed to fetch cities: ${e.toString()}',
          stackTrace: stack,
        ),
      );
    }
  }

  @override
  Future<Either<NetworkFailure, List<CityModel>>> getPopularCities() async {
    return await Future.delayed(oneSecond, () => right(defaultCities));
  }

  @override
  Future<Either<NetworkFailure, List<CityModel>>> filterCities(
    String query,
  ) async {
    if (query.isEmpty) {
      return right([]);
    }

    final cities = await _loadCitiesFromAsset();
    return right(
      cities
          .where(
            (city) => city.name.toLowerCase().contains(query.toLowerCase()),
          )
          .toList(),
    );
  }

  Future<List<CityModel>> _loadCitiesFromAsset() async {
    if (_cachedCities != null) {
      return _cachedCities!;
    }

    try {
      final jsonString = await rootBundle.loadString('assets/data/cities.json');
      final List<dynamic> jsonData = json.decode(jsonString);
      _cachedCities = jsonData.map((json) => CityModel.fromJson(json)).toList();
      return _cachedCities!;
    } catch (e) {
      return [];
    }
  }

  List<CityModel> _convertCity(dynamic data) {
    // Convert List<dynamic> to List<CityModel>
    if (data is List) {
      return data
          .map((item) => CityModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Invalid response format');
  }
}

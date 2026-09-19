import 'package:dio/dio.dart';
import 'package:freelance_front/core/constants/api_endpoints.dart';
import 'package:freelance_front/core/services/common/api_client.dart';
import 'package:freelance_front/core/models/common/location_model.dart';

class LocationService {
  final Dio _dio = ApiClient.instance;

  Future<List<CountryModel>> getCountries() async {
    final response = await _dio.get(ApiEndpoints.locationsCountries);
    if (response.statusCode != 200) throw Exception('Erreur chargement pays');
    return (response.data as List).map((e) => CountryModel.fromJson(e)).toList();
  }

  Future<List<CityModel>> getCities(int countryId) async {
    final response = await _dio.get(ApiEndpoints.locationsCities(countryId));
    if (response.statusCode != 200) throw Exception('Erreur chargement villes');
    return (response.data as List).map((e) => CityModel.fromJson(e)).toList();
  }

  Future<List<DistrictModel>> getDistricts(int cityId) async {
    final response = await _dio.get(ApiEndpoints.locationsDistricts(cityId));
    if (response.statusCode != 200) throw Exception('Erreur chargement quartiers');
    return (response.data as List).map((e) => DistrictModel.fromJson(e)).toList();
  }
}

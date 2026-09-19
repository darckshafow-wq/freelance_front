class CountryModel {
  final int id;
  final String name;
  final String code;
  final bool isActive;
  final List<CityModel> cities;

  CountryModel({
    required this.id,
    required this.name,
    required this.code,
    required this.isActive,
    this.cities = const [],
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    return CountryModel(
      id: json['id'] as int,
      name: json['name'] as String,
      code: json['code'] as String,
      isActive: json['is_active'] as bool? ?? true,
      cities: (json['cities'] as List?)?.map((c) => CityModel.fromJson(c)).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'is_active': isActive,
      'cities': cities.map((c) => c.toJson()).toList(),
    };
  }
}

class CityModel {
  final int id;
  final String name;
  final int countryId;
  final double latitude;
  final double longitude;
  final bool isActive;
  final List<DistrictModel> districts;

  CityModel({
    required this.id,
    required this.name,
    required this.countryId,
    required this.latitude,
    required this.longitude,
    required this.isActive,
    this.districts = const [],
  });

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      id: json['id'] as int,
      name: json['name'] as String,
      countryId: json['country_id'] as int,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      isActive: json['is_active'] as bool? ?? true,
      districts: (json['districts'] as List?)?.map((d) => DistrictModel.fromJson(d)).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'country_id': countryId,
      'latitude': latitude,
      'longitude': longitude,
      'is_active': isActive,
      'districts': districts.map((d) => d.toJson()).toList(),
    };
  }
}

class DistrictModel {
  final int id;
  final String name;
  final int cityId;
  final double latitude;
  final double longitude;
  final bool isActive;

  DistrictModel({
    required this.id,
    required this.name,
    required this.cityId,
    required this.latitude,
    required this.longitude,
    required this.isActive,
  });

  factory DistrictModel.fromJson(Map<String, dynamic> json) {
    return DistrictModel(
      id: json['id'] as int,
      name: json['name'] as String,
      cityId: json['city_id'] as int,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'city_id': cityId,
      'latitude': latitude,
      'longitude': longitude,
      'is_active': isActive,
    };
  }
}

import 'package:freelance_front/core/models/common/user_model.dart';
import 'package:freelance_front/core/models/common/proposal_model.dart';
import 'package:freelance_front/core/models/common/location_model.dart';

class ProjectModel {
  final int id;
  final String title;
  final String description;
  final String status;
  final DateTime executionDate;
  final String? localisation; 
  final int? countryId;
  final int? cityId;
  final int? districtId;
  final double? latitude;
  final double? longitude;
  final String? imageUrl;
  final int? categoryId;
  final double budget;
  final String? category;
  final List<String> skills;
  final int proposalsCount;
  final UserModel? client;
  final List<ProposalModel> proposals;
  
  final CountryModel? country;
  final CityModel? city;
  final DistrictModel? district;

  ProjectModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.executionDate,
    this.localisation,
    this.countryId,
    this.cityId,
    this.districtId,
    this.latitude,
    this.longitude,
    this.imageUrl,
    this.categoryId,
    required this.budget,
    this.category,
    this.skills = const [],
    this.proposalsCount = 0,
    this.client,
    this.proposals = const [],
    this.country,
    this.city,
    this.district,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    var rawBudget = json['budget'] ?? 
                    json['price'] ?? 
                    json['amount'] ?? 
                    json['total_price'] ?? 
                    json['reward'] ?? 
                    json['estimated_budget'];
    
    if (rawBudget == null && json['proposals'] != null && (json['proposals'] as List).isNotEmpty) {
       rawBudget = json['proposals'][0]['proposed_price'];
    }

    final double parsedBudget = double.tryParse(rawBudget?.toString() ?? '0') ?? 0.0;

    return ProjectModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'OPEN',
      executionDate: DateTime.tryParse((json['scheduled_at'] ?? json['execution_date'] ?? '').toString()) ?? DateTime.now(),
      localisation: json['localisation'] as String?,
      countryId: json['country_id'] as int?,
      cityId: json['city_id'] as int?,
      districtId: json['district_id'] as int?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      imageUrl: json['image_url'] as String?,
      categoryId: json['category_id'] as int?,
      budget: parsedBudget,
      category: json['category'] is Map ? json['category']['name'] as String? : json['category'] as String?,
      skills: (json['skills'] as List?)?.map((e) => e.toString()).toList() ?? [],
      proposalsCount: json['proposals_count'] ?? 0,
      client: json['client'] != null ? UserModel.fromJson(Map<String, dynamic>.from(json['client'])) : null,
      proposals: (json['proposals'] as List?)
              ?.map((e) => ProposalModel.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          [],
      country: json['country'] != null ? CountryModel.fromJson(Map<String, dynamic>.from(json['country'])) : null,
      city: json['city'] != null ? CityModel.fromJson(Map<String, dynamic>.from(json['city'])) : null,
      district: json['district'] != null ? DistrictModel.fromJson(Map<String, dynamic>.from(json['district'])) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'localisation': localisation,
        'country_id': countryId,
        'city_id': cityId,
        'district_id': districtId,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (imageUrl != null) 'image_url': imageUrl,
        'scheduled_at': executionDate.toIso8601String(),
        if (categoryId != null) 'category_id': categoryId,
        'budget': budget,
      };

  ProjectModel copyWith({
    String? localisation,
    String? imageUrl, 
    double? latitude, 
    double? longitude,
    int? countryId,
    int? cityId,
    int? districtId,
  }) {
    return ProjectModel(
      id: id,
      title: title,
      description: description,
      status: status,
      executionDate: executionDate,
      localisation: localisation ?? this.localisation,
      countryId: countryId ?? this.countryId,
      cityId: cityId ?? this.cityId,
      districtId: districtId ?? this.districtId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imageUrl: imageUrl ?? this.imageUrl,
      categoryId: categoryId,
      budget: budget,
      category: category,
      skills: skills,
      proposalsCount: proposalsCount,
      client: client,
      proposals: proposals,
      country: country,
      city: city,
      district: district,
    );
  }
}

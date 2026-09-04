import 'package:json_annotation/json_annotation.dart';

part 'profile_model.g.dart';

@JsonSerializable()
class ProfileModel {
  final int id;
  @JsonKey(name: 'user_id')
  final int userId;
  final String? bio;
  final List<String>? skills;
  @JsonKey(name: 'rating_average')
  final double? ratingAverage;
  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;
  @JsonKey(name: 'identity_verified')
  final bool identityVerified;

  ProfileModel({
    required this.id,
    required this.userId,
    this.bio,
    this.skills,
    this.ratingAverage,
    this.avatarUrl,
    this.identityVerified = false,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) => _$ProfileModelFromJson(json);
  Map<String, dynamic> toJson() => _$ProfileModelToJson(this);
}

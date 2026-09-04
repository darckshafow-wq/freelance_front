import 'package:json_annotation/json_annotation.dart';
import 'package:freelance_front/core/models/common/profile_model.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final int id;
  final String email;
  @JsonKey(name: 'full_name')
  final String fullName;
  final String role;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'is_suspended')
  final bool isSuspended;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'failed_login_attempts')
  final int? failedLoginAttempts;
  @JsonKey(name: 'last_failed_login')
  final DateTime? lastFailedLogin;
  final ProfileModel? profile;

  UserModel({
    required this.id,
    this.email = '',
    this.fullName = '',
    this.role = 'user',
    this.isActive = true,
    this.isSuspended = false,
    this.createdAt,
    this.failedLoginAttempts,
    this.lastFailedLogin,
    this.profile,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}

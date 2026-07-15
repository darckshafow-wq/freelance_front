enum UserRole {
  client,
  freelancer,
  admin;

  static UserRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'client':
        return UserRole.client;
      case 'freelancer':
      case 'freelance':
        return UserRole.freelancer;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.freelancer;
    }
  }

  static UserRole fromBooleans({
    bool isAdmin = false,
    bool isClient = false,
    bool isFreelancer = false,
  }) {
    if (isAdmin) return UserRole.admin;
    if (isClient) return UserRole.client;
    return UserRole.freelancer;
  }

  String toJson() => name;
}

class UserModel {
  final int id;
  final String email;
  final String fullName;
  final UserRole role;
  final String? phoneNumber;
  final DateTime? createdAt;

  final bool isActive;
  final bool isClient;
  final bool isFreelancer;
  final bool isAdmin;
  final bool isVerified;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.phoneNumber,
    this.createdAt,
    this.isActive = true,
    this.isClient = false,
    this.isFreelancer = false,
    this.isAdmin = false,
    this.isVerified = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final UserRole role;

    // Récupération sécurisée et typée du sous-objet 'roles'
    final Map<String, dynamic>? rolesJson = json['roles'] is Map
        ? Map<String, dynamic>.from(json['roles'] as Map)
        : null;

    if (json['role'] != null) {
      role = UserRole.fromString(json['role'].toString());
    } else if (rolesJson != null) {
      role = UserRole.fromBooleans(
        isAdmin: rolesJson['is_admin'] as bool? ?? false,
        isClient: rolesJson['is_client'] as bool? ?? false,
        isFreelancer: rolesJson['is_freelancer'] as bool? ?? false,
      );
    } else {
      role = UserRole.freelancer;
    }

    final parsedId = int.tryParse(json['id']?.toString() ?? '') ?? 0;
    print('=== DEBUG UserModel.fromJson ===');
    print('Raw JSON id: ${json['id']}');
    print('Parsed ID: $parsedId');
    print('Raw JSON email: ${json['email']}');
    print('=================================');

    return UserModel(
      id: parsedId,
      email: (json['email'] ?? '').toString(),
      fullName:
          (json['full_name'] ??
                  json['fullName'] ??
                  json['pseudo'] ??
                  json['name'] ??
                  '')
              .toString(),
      role: role,
      phoneNumber:
          json['phoneNumber']?.toString() ?? json['phone_number']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      isActive: json['is_active'] as bool? ?? true,
      isVerified: json['is_verified'] as bool? ?? false,
      isClient:
          rolesJson?['is_client'] as bool? ??
          json['is_client'] as bool? ??
          (role == UserRole.client),
      isFreelancer:
          rolesJson?['is_freelancer'] as bool? ??
          json['is_freelancer'] as bool? ??
          (role == UserRole.freelancer),
      isAdmin:
          rolesJson?['is_admin'] as bool? ??
          json['is_admin'] as bool? ??
          (role == UserRole.admin),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'role': role.toJson(),
      'phone_number': phoneNumber,
      'created_at': createdAt?.toIso8601String(),
      'is_active': isActive,
      'is_client': isClient,
      'is_freelancer': isFreelancer,
      'is_admin': isAdmin,
    };
  }

  @override
  String toString() => 'UserModel(id: $id, email: $email, role: ${role.name})';
}

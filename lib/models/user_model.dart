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

  /// Calcule le rôle depuis les booléens renvoyés par le backend réel.
  /// Utile lors de la migration depuis le système is_client/is_freelancer.
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

  // Champs additionnels du backend réel
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
    // Support du champ 'role' string (mock + backend réel via /users/me)
    // ET support des booléens is_client/is_freelancer (endpoint /users/{id})
    final UserRole role;
    if (json['role'] != null) {
      role = UserRole.fromString(json['role'] as String);
    } else {
      role = UserRole.fromBooleans(
        isAdmin: json['is_admin'] as bool? ?? false,
        isClient: json['is_client'] as bool? ?? false,
        isFreelancer: json['is_freelancer'] as bool? ?? false,
      );
    }

    return UserModel(
      id: json['id'] as int,
      email: json['email'] as String,
      fullName: json['fullName'] ?? json['full_name'] ?? '',
      role: role,
      phoneNumber: json['phoneNumber'] ?? json['phone_number'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      isActive: json['is_active'] as bool? ?? true,
      isClient: json['is_client'] as bool? ?? (role == UserRole.client),
      isFreelancer:
          json['is_freelancer'] as bool? ?? (role == UserRole.freelancer),
      isAdmin: json['is_admin'] as bool? ?? (role == UserRole.admin),
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
  String toString() =>
      'UserModel(id: $id, email: $email, role: ${role.name})';
}

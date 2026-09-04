class CategoryModel {
  final int id;
  final String name;
  final bool isActive;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.isActive,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'is_active': isActive,
      };
}

class ProjectModel {
  final int id;
  final String title;
  final String description;
  final String status;
  final DateTime executionDate;
  final String? localisation;
  final int? categoryId;
  final double budget;
  final String? category;
  final List<String> skills;
  final int proposalsCount;

  ProjectModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.executionDate,
    this.localisation,
    this.categoryId,
    required this.budget,
    this.category,
    this.skills = const [],
    this.proposalsCount = 0,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'OPEN',
      executionDate: DateTime.tryParse((json['scheduled_at'] ?? json['execution_date'] ?? '').toString()) ?? DateTime.now(),
      localisation: json['localisation'] as String?,
      categoryId: json['category_id'] as int?,
      budget: (json['budget'] as num?)?.toDouble() ?? 0.0,
      category: json['category'],
      skills: (json['skills'] as List?)?.map((e) => e.toString()).toList() ?? [],
      proposalsCount: json['proposals_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'localisation': localisation,
        'scheduled_at': executionDate.toIso8601String(),
        if (categoryId != null) 'category_id': categoryId,
      };
}

class AdminStatsModel {
  final UsersStats users;
  final TasksStats tasks;
  final ApplicationsStats applications;
  final MessagesStats messages;
  final PercentagesStats percentages;
  final List<MonthlyActivity> activityHistory;

  AdminStatsModel({
    required this.users,
    required this.tasks,
    required this.applications,
    required this.messages,
    required this.percentages,
    required this.activityHistory,
  });

  factory AdminStatsModel.fromJson(Map<String, dynamic> json) {
    return AdminStatsModel(
      users: UsersStats.fromJson(json['users'] ?? {}),
      tasks: TasksStats.fromJson(json['tasks'] ?? {}),
      applications: ApplicationsStats.fromJson(json['applications'] ?? {}),
      messages: MessagesStats.fromJson(json['messages'] ?? {}),
      percentages: PercentagesStats.fromJson(json['percentages'] ?? {}),
      activityHistory: (json['activityHistory'] as List? ?? [])
          .map((e) => MonthlyActivity.fromJson(e))
          .toList(),
    );
  }
}

class MonthlyActivity {
  final String name;
  final int tasks;
  final int users;

  MonthlyActivity({
    required this.name,
    required this.tasks,
    required this.users,
  });

  factory MonthlyActivity.fromJson(Map<String, dynamic> json) {
    return MonthlyActivity(
      name: json['name'] ?? '',
      tasks: json['tasks'] ?? 0,
      users: json['users'] ?? 0,
    );
  }
}

class UsersStats {
  final int total;
  final int freelancers;
  final int clients;
  final int admins;

  UsersStats({
    required this.total,
    required this.freelancers,
    required this.clients,
    required this.admins,
  });

  factory UsersStats.fromJson(Map<String, dynamic> json) {
    return UsersStats(
      total: json['total'] ?? 0,
      freelancers: json['freelancers'] ?? 0,
      clients: json['clients'] ?? 0,
      admins: json['admins'] ?? 0,
    );
  }
}

class TasksStats {
  final int total;
  final int pending;
  final int validated;
  final int appliedTo;

  TasksStats({
    required this.total,
    required this.pending,
    required this.validated,
    required this.appliedTo,
  });

  factory TasksStats.fromJson(Map<String, dynamic> json) {
    return TasksStats(
      total: json['total'] ?? 0,
      pending: json['pending'] ?? 0,
      validated: json['validated'] ?? 0,
      appliedTo: json['applied_to'] ?? 0,
    );
  }
}

class ApplicationsStats {
  final int total;
  final int pending;

  ApplicationsStats({
    required this.total,
    required this.pending,
  });

  factory ApplicationsStats.fromJson(Map<String, dynamic> json) {
    return ApplicationsStats(
      total: json['total'] ?? 0,
      pending: json['pending'] ?? 0,
    );
  }
}

class MessagesStats {
  final int total;

  MessagesStats({
    required this.total,
  });

  factory MessagesStats.fromJson(Map<String, dynamic> json) {
    return MessagesStats(
      total: json['total'] ?? 0,
    );
  }
}

class PercentagesStats {
  final double siteActivity;
  final RegistrationPercentages registration;
  final TasksPercentages tasks;

  PercentagesStats({
    required this.siteActivity,
    required this.registration,
    required this.tasks,
  });

  factory PercentagesStats.fromJson(Map<String, dynamic> json) {
    return PercentagesStats(
      siteActivity: (json['site_activity'] ?? 0).toDouble(),
      registration: RegistrationPercentages.fromJson(json['registration'] ?? {}),
      tasks: TasksPercentages.fromJson(json['tasks'] ?? {}),
    );
  }
}

class RegistrationPercentages {
  final double freelancers;
  final double clients;

  RegistrationPercentages({
    required this.freelancers,
    required this.clients,
  });

  factory RegistrationPercentages.fromJson(Map<String, dynamic> json) {
    return RegistrationPercentages(
      freelancers: (json['freelancers'] ?? 0).toDouble(),
      clients: (json['clients'] ?? 0).toDouble(),
    );
  }
}

class TasksPercentages {
  final double validated;
  final double applied;

  TasksPercentages({
    required this.validated,
    required this.applied,
  });

  factory TasksPercentages.fromJson(Map<String, dynamic> json) {
    return TasksPercentages(
      validated: (json['validated'] ?? 0).toDouble(),
      applied: (json['applied'] ?? 0).toDouble(),
    );
  }
}

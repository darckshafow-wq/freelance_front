enum AppRole { client, freelance, admin }

class RoleAccess {
  static const Map<AppRole, Map<String, Set<String>>> tableAccess = {
    AppRole.client: {
      'user': {'read', 'update:email', 'update:full_name', 'update:two_factor_enabled'},
      'profile': {'read', 'update:bio', 'update:skills', 'update:avatar_url'},
      'project': {'read', 'create', 'update:status', 'update:localisation', 'update:title', 'update:description'},
      'proposal': {'read', 'update:status'},
      'message': {'read', 'write', 'update:is_read'},
      'notification': {'read', 'update:is_read'},
      'review': {'read', 'write'},
      'report': {'read', 'write'},
      'feedback': {'read', 'write'},
      'category': {'read'},
    },
    AppRole.freelance: {
      'user': {'read', 'update:email', 'update:full_name', 'update:two_factor_enabled'},
      'profile': {'read', 'update:bio', 'update:skills', 'update:avatar_url'},
      'project': {'read'},
      'proposal': {'read', 'write', 'update:status'},
      'message': {'read', 'write', 'update:is_read'},
      'notification': {'read', 'update:is_read'},
      'review': {'read', 'write'},
      'report': {'read', 'write'},
      'feedback': {'read', 'write'},
      'category': {'read'},
    },
    AppRole.admin: {
      'user': {'read', 'update', 'suspend', 'activate', 'verify_identity'},
      'profile': {'read', 'update', 'verify_identity'},
      'project': {'read', 'delete', 'update:status'},
      'proposal': {'read', 'update:status'},
      'message': {'read', 'write', 'update:is_read'},
      'notification': {'read', 'write', 'update:is_read'},
      'review': {'read', 'write'},
      'report': {'read', 'update:status'},
      'feedback': {'read', 'write', 'update:status'},
      'category': {'read', 'create', 'update'},
      'audit_log': {'read', 'write'},
      'system_warning': {'read', 'write', 'update:is_resolved'},
    },
  };

  static bool canAccess(AppRole role, String table, String action) {
    final actions = tableAccess[role]?[table] ?? const <String>{};
    return actions.contains(action) ||
        actions.contains('read') && action.startsWith('read') ||
        actions.contains('update') && action.startsWith('update');
  }
}

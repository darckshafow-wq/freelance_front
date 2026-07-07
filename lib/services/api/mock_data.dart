import '../../models/user_model.dart';
import '../../models/task_model.dart';
import '../../models/notification.dart';
import 'api_response.dart';

class MockData {
  // Flag global pour activer/désactiver le mock.
  // Activé par défaut pour permettre le test immédiat sans serveur.
  // Mock désactivé par défaut (backend réel). Pour forcer le mock :
  // flutter run --dart-define=USE_MOCK=true
  static const bool useMock = bool.fromEnvironment('USE_MOCK', defaultValue: false);

  static final List<UserModel> _users = [
    UserModel(
      id: 1,
      email: 'client@example.com',
      fullName: 'Jean Client',
      role: UserRole.client,
      phoneNumber: '+33612345678',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    UserModel(
      id: 2,
      email: 'freelance@example.com',
      fullName: 'Sophie Dev',
      role: UserRole.freelancer,
      phoneNumber: '+33698765432',
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
    UserModel(
      id: 3,
      email: 'admin@example.com',
      fullName: 'Marc Admin',
      role: UserRole.admin,
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
    ),
  ];

  static final List<TaskModel> _tasks = [
    TaskModel(
      id: 1,
      title: 'Création Application Mobile Flutter',
      description: 'Développement d\'une application mobile complète de mise en relation de freelances en utilisant Flutter et FastAPI en backend. Le design doit être premium et moderne.',
      budget: 2500.0,
      status: TaskStatus.pending,
      clientId: 1,
      deadline: DateTime.now().add(const Duration(days: 30)),
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    TaskModel(
      id: 2,
      title: 'Intégration API Stripe',
      description: 'Mettre en place le système de paiement récurrent Stripe sur une plateforme web existante. Gestion des webhooks et des remboursements.',
      budget: 1200.0,
      status: TaskStatus.validated,
      clientId: 1,
      deadline: DateTime.now().add(const Duration(days: 15)),
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    TaskModel(
      id: 3,
      title: 'Audit de sécurité Cloud AWS',
      description: 'Audit complet de la configuration AWS, politiques IAM et base de données MySQL. Fournir un rapport complet des vulnérabilités.',
      budget: 4000.0,
      status: TaskStatus.executed,
      clientId: 1,
      deadline: DateTime.now().subtract(const Duration(days: 1)),
      createdAt: DateTime.now().subtract(const Duration(days: 12)),
    ),
  ];

  // Utilisateur actuellement "connecté" en mémoire
  static UserModel? _currentUser;

  // --- Gestion de l'Authentification ---

  static Future<ApiResponse<Map<String, dynamic>>> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800)); // Simuler délai réseau

    try {
      final userIndex = _users.indexWhere((u) => u.email.toLowerCase() == email.toLowerCase().trim());
      if (userIndex != -1) {
        // Dans un cas réel, on vérifie le mot de passe.
        // Ici, on accepte n'importe quel mot de passe de plus de 5 caractères pour faciliter le test.
        if (password.length >= 6) {
          _currentUser = _users[userIndex];
          return ApiResponse.success({
            'access_token': 'mock-jwt-token-for-${_currentUser!.id}',
            'token_type': 'bearer',
          }, statusCode: 200);
        } else {
          return ApiResponse.error('Le mot de passe doit contenir au moins 6 caractères.', statusCode: 400);
        }
      } else {
        return ApiResponse.error('Identifiants incorrects ou utilisateur inexistant.', statusCode: 400);
      }
    } catch (e) {
      return ApiResponse.error('Erreur d\'authentification : $e');
    }
  }

  static Future<ApiResponse<UserModel>> register(Map<String, dynamic> body) async {
    await Future.delayed(const Duration(milliseconds: 800));

    try {
      final email = body['email'] as String;
      final emailExists = _users.any((u) => u.email.toLowerCase() == email.toLowerCase().trim());
      if (emailExists) {
        return ApiResponse.error('Cette adresse e-mail est déjà utilisée.', statusCode: 400);
      }

      final newUser = UserModel(
        id: _users.length + 1,
        email: email,
        fullName: body['full_name'] as String? ?? '',
        role: UserRole.fromString(body['role'] as String? ?? 'freelancer'),
        phoneNumber: body['phone_number'] as String?,
        createdAt: DateTime.now(),
      );

      _users.add(newUser);
      return ApiResponse.success(newUser, statusCode: 201);
    } catch (e) {
      return ApiResponse.error('Erreur lors de l\'inscription : $e');
    }
  }

  static Future<ApiResponse<UserModel>> getMe(String? token) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Rehydrate currentUser from token if it was lost (app restart)
    if (_currentUser == null && token != null && token.startsWith('mock-jwt-token-for-')) {
      final idStr = token.replaceAll('mock-jwt-token-for-', '');
      final id = int.tryParse(idStr);
      if (id != null) {
        try {
          _currentUser = _users.firstWhere((u) => u.id == id);
        } catch (_) {}
      }
    }

    if (_currentUser != null) {
      return ApiResponse.success(_currentUser!, statusCode: 200);
    }
    return ApiResponse.error('Non autorisé', statusCode: 401);
  }

  static void logout() {
    _currentUser = null;
  }

  /// Résout le rôle d'un utilisateur à partir de son ID.
  /// Utilisé par le routeur pour vérifier les droits d'accès sans Provider.
  static UserRole? getRoleForUserId(int userId) {
    try {
      final user = _users.firstWhere((u) => u.id == userId);
      return user.role;
    } catch (_) {
      return null;
    }
  }

  // --- Gestion des Tâches ---

  static Future<ApiResponse<List<TaskModel>>> getTasks() async {
    await Future.delayed(const Duration(milliseconds: 600));
    // Renvoyer une copie pour éviter la mutation externe directe
    return ApiResponse.success(List<TaskModel>.from(_tasks), statusCode: 200);
  }

  static Future<ApiResponse<TaskModel>> createTask(Map<String, dynamic> body) async {
    await Future.delayed(const Duration(milliseconds: 700));
    try {
      final newTask = TaskModel(
        id: _tasks.isEmpty ? 1 : _tasks.map((t) => t.id).reduce((a, b) => a > b ? a : b) + 1,
        title: body['title'] as String? ?? 'Sans titre',
        description: body['description'] as String? ?? '',
        budget: (body['budget'] as num?)?.toDouble() ?? 0.0,
        status: TaskStatus.pending,
        clientId: _currentUser?.id ?? 1,
        deadline: body['deadline'] != null ? DateTime.parse(body['deadline']) : null,
        createdAt: DateTime.now(),
      );
      _tasks.add(newTask);
      return ApiResponse.success(newTask, statusCode: 201);
    } catch (e) {
      return ApiResponse.error('Erreur création tâche : $e');
    }
  }

  static Future<ApiResponse<TaskModel>> updateTask(int id, Map<String, dynamic> updates) async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      final index = _tasks.indexWhere((t) => t.id == id);
      if (index == -1) {
        return ApiResponse.error('Mission introuvable', statusCode: 404);
      }

      final existing = _tasks[index];
      final updated = TaskModel(
        id: existing.id,
        title: updates['title'] as String? ?? existing.title,
        description: updates['description'] as String? ?? existing.description,
        budget: (updates['budget'] as num?)?.toDouble() ?? existing.budget,
        status: updates['status'] != null 
            ? TaskStatus.values.firstWhere((e) => e.name == updates['status'], orElse: () => existing.status) 
            : existing.status,
        clientId: existing.clientId,
        deadline: updates['deadline'] != null ? DateTime.parse(updates['deadline']) : existing.deadline,
        createdAt: existing.createdAt,
      );

      _tasks[index] = updated;
      return ApiResponse.success(updated, statusCode: 200);
    } catch (e) {
      return ApiResponse.error('Erreur modification tâche : $e');
    }
  }

  static Future<ApiResponse<Map<String, dynamic>>> deleteTask(int id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) {
      return ApiResponse.error('Mission introuvable', statusCode: 404);
    }
    _tasks.removeAt(index);
    return ApiResponse.success({'deleted': true, 'id': id}, statusCode: 200);
  }

  // --- Gestion des Notifications ---

  static final Map<int, List<NotificationModel>> _notifications = {
    1: [
      NotificationModel(
        id: 1,
        title: 'Nouvelle candidature reçue',
        body: 'Sophie Dev a postulé sur votre mission "Création Application Mobile Flutter".',
        type: NotificationType.newApplication,
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
        relatedId: 1,
        actionRoute: '/smartphone/client/missions/mission_detail_view',
      ),
      NotificationModel(
        id: 2,
        title: 'Mission validée',
        body: 'Votre mission "Intégration API Stripe" a été validée et est en cours d\'exécution.',
        type: NotificationType.missionValidated,
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        relatedId: 2,
        actionRoute: '/smartphone/client/missions/mission_detail_view',
      ),
      NotificationModel(
        id: 3,
        title: 'Mission terminée',
        body: 'Votre mission "Audit de sécurité Cloud AWS" a été marquée comme terminée.',
        type: NotificationType.missionCompleted,
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        relatedId: 3,
      ),
      NotificationModel(
        id: 4,
        title: 'Bienvenue sur la plateforme !',
        body: 'Votre compte client a été créé avec succès. Postez votre première mission dès maintenant.',
        type: NotificationType.system,
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
    ],
    2: [
      NotificationModel(
        id: 5,
        title: 'Candidature acceptée !',
        body: 'Votre candidature pour "Création Application Mobile Flutter" a été acceptée.',
        type: NotificationType.applicationAccepted,
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        relatedId: 1,
        actionRoute: '/freelance/job-detail',
      ),
      NotificationModel(
        id: 6,
        title: 'Nouveau paiement reçu',
        body: 'Vous avez reçu un paiement de 4 000 F CFA pour la mission "Audit de sécurité Cloud AWS".',
        type: NotificationType.paymentReceived,
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      NotificationModel(
        id: 7,
        title: 'Candidature refusée',
        body: 'Votre candidature pour "Intégration API Stripe" n\'a pas été retenue cette fois.',
        type: NotificationType.applicationRejected,
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ],
  };

  static Future<ApiResponse<List<NotificationModel>>> getNotifications() async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (_currentUser == null) {
      return ApiResponse.error('Non autorisé', statusCode: 401);
    }
    final userNotifs = _notifications[_currentUser!.id] ?? [];
    final sorted = List<NotificationModel>.from(userNotifs)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return ApiResponse.success(sorted, statusCode: 200);
  }

  static Future<ApiResponse<NotificationModel>> markNotificationAsRead(int notifId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (_currentUser == null) {
      return ApiResponse.error('Non autorisé', statusCode: 401);
    }
    final userNotifs = _notifications[_currentUser!.id];
    if (userNotifs == null) return ApiResponse.error('Introuvable', statusCode: 404);
    final index = userNotifs.indexWhere((n) => n.id == notifId);
    if (index == -1) return ApiResponse.error('Introuvable', statusCode: 404);
    userNotifs[index] = userNotifs[index].copyWith(isRead: true);
    return ApiResponse.success(userNotifs[index], statusCode: 200);
  }

  static Future<ApiResponse<Map<String, dynamic>>> markAllNotificationsAsRead() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (_currentUser == null) {
      return ApiResponse.error('Non autorisé', statusCode: 401);
    }
    final userNotifs = _notifications[_currentUser!.id];
    if (userNotifs != null) {
      for (int i = 0; i < userNotifs.length; i++) {
        userNotifs[i] = userNotifs[i].copyWith(isRead: true);
      }
    }
    return ApiResponse.success({'updated': true}, statusCode: 200);
  }

  static Future<ApiResponse<Map<String, dynamic>>> deleteNotification(int notifId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (_currentUser == null) {
      return ApiResponse.error('Non autorisé', statusCode: 401);
    }
    final userNotifs = _notifications[_currentUser!.id];
    if (userNotifs == null) return ApiResponse.error('Introuvable', statusCode: 404);
    userNotifs.removeWhere((n) => n.id == notifId);
    return ApiResponse.success({'deleted': true, 'id': notifId}, statusCode: 200);
  }

  static int getUnreadCount() {
    if (_currentUser == null) return 0;
    final userNotifs = _notifications[_currentUser!.id] ?? [];
    return userNotifs.where((n) => !n.isRead).length;
  }
}

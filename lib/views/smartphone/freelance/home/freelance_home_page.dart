import 'package:flutter/material.dart';
import '../../../../constants/app_colors.dart';
import '../../../../routes/app_router.dart';
import '../../../../controllers/auth/auth_controller.dart';
import '../../../../controllers/shared/notification_controller.dart';
import '../../../../controllers/freelance/task_controller.dart';
import '../../../../models/client/task_model.dart';
import '../../../../controllers/freelance/profil_controller.dart';
import '../../../../models/auth/user_model.dart';

class FreelanceHomePage extends StatefulWidget {
  final String userId;
  final AuthController? authController;

  const FreelanceHomePage({
    super.key,
    required this.userId,
    this.authController,
  });

  @override
  State<FreelanceHomePage> createState() => _FreelanceHomePageState();
}

class _FreelanceHomePageState extends State<FreelanceHomePage> {
  final FreelanceTaskController _taskController = FreelanceTaskController();
  late final NotificationController _notificationController;

  // Instance du contrôleur de profil
  final ProfilController _profilController = ProfilController();

  // État local pour stocker les informations de l'utilisateur connecté
  UserModel? _currentUser;
  bool _isProfileLoading = true;

  @override
  void initState() {
    super.initState();
    _notificationController = NotificationController(
      role: widget.authController?.currentUser?.role,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      // 1. Chargement initial des tâches et notifications
      _taskController.fetchHomeTasks();
      _notificationController.fetchNotifications();

      // 2. Résolution de l'ID utilisateur
      final currentUserId = ProfilController.resolveUserId(
        widget.userId,
        currentUserId: widget.authController?.currentUser?.id,
      );

      final resolvedUserId =
          currentUserId ?? widget.authController?.currentUser?.id ?? 0;

      // 3. Récupération conforme du profil via le ProfilController
      try {
        setState(() => _isProfileLoading = true);

        // Récupération de l'utilisateur (getUserInfo gère le fallback si resolvedUserId <= 0)
        final user = await _profilController.getUserInfo(resolvedUserId);

        if (mounted) {
          setState(() {
            _currentUser = user;
            _isProfileLoading = false;
          });
        }

        // Chargement parallèle optionnel des stats du freelance en tâche de fond si nécessaire
        if (resolvedUserId > 0) {
          await _profilController.loadFullProfile(userId: resolvedUserId);
        }
      } catch (e) {
        debugPrint("[Home] Erreur de récupération du profil : $e");
        if (mounted) {
          setState(() => _isProfileLoading = false);
        }
      }
    });
  }

  @override
  void dispose() {
    // Note : Le ProfilController n'a pas de méthode dispose() définie,
    // on ne libère donc que les contrôleurs qui en ont besoin.
    _taskController.dispose();
    _notificationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      appBar: AppBar(
        title: const Text(
          'Missions disponibles',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            onPressed: () async {
              await Navigator.pushNamed(
                context,
                AppRoutes.notifications,
                arguments: widget.authController,
              );
            },
            icon: AnimatedBuilder(
              animation: _notificationController,
              builder: (context, _) {
                return Badge(
                  isLabelVisible: _notificationController.unreadCount > 0,
                  label: Text(
                    '${_notificationController.unreadCount}',
                    style: const TextStyle(fontSize: 10),
                  ),
                  backgroundColor: AppColors.error,
                  child: const Icon(Icons.notifications_outlined),
                );
              },
            ),
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Rechercher une mission...',
                  hintStyle: const TextStyle(color: Colors.black38),
                  prefixIcon: const Icon(Icons.search, color: Colors.black45),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: Colors.black.withValues(alpha: 0.05),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: Colors.black.withValues(alpha: 0.05),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Actualité des missions',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),

              ListenableBuilder(
                listenable: _taskController,
                builder: (context, child) {
                  if (_taskController.isLoading) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: CircularProgressIndicator(
                          color: Color(0xFFFFB000),
                        ),
                      ),
                    );
                  }

                  if (_taskController.errorMessage != null) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            Text(
                              _taskController.errorMessage!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () => _taskController.fetchHomeTasks(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFB000),
                              ),
                              child: const Text(
                                'Réessayer',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (_taskController.homeTasks.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: Text(
                          "Aucune mission disponible pour le moment.",
                          style: TextStyle(color: Colors.black45, fontSize: 16),
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _taskController.homeTasks.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 24),
                    itemBuilder: (context, index) {
                      final TaskModel task = _taskController.homeTasks[index];

                      return _MissionCard(
                        title: task.title,
                        description: task.description.isNotEmpty
                            ? task.description
                            : 'Mission publiée sur la plateforme.',
                        budget: '${task.budget.toStringAsFixed(0)} F CFA',
                        clientName: task.clientId > 0
                            ? 'Client #'
                            : 'Client partenaire',
                        duration: task.deadline != null
                            ? '${task.deadline!.difference(DateTime.now()).inDays} jours restants'
                            : (task.location?.isNotEmpty == true
                                  ? task.location!
                                  : 'Flexible'),
                        tags: [
                          task.location?.isNotEmpty == true
                              ? task.location!
                              : 'Remote',
                          task.status.name.toUpperCase(),
                        ],
                        onTap: () {
                          if (!mounted) return;
                          Navigator.pushNamed(
                            context,
                            '/freelance/job-detail',
                            arguments: {
                              'id': task.id,
                              'title': task.title,
                              'description': task.description,
                              'budget':
                                  '${task.budget.toStringAsFixed(0)} F CFA',
                              'budgetValue': task.budget,
                              'deadline': task.deadline?.toIso8601String(),
                              'clientId': task.clientId,
                              'location': task.location,
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    // Utilisation de l'état local du profil mis à jour
    final displayName = _currentUser?.fullName ?? 'Utilisateur';
    final userRoleLabel = _currentUser?.role == UserRole.client
        ? 'Client'
        : 'Freelancer';

    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(
              top: 60,
              left: 24,
              right: 24,
              bottom: 24,
            ),
            color: const Color(0xFFFDFBF7),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFFFB000),
                      width: 2,
                    ),
                  ),
                  child: const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person_pin,
                      size: 40,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_isProfileLoading)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFFFFB000),
                          ),
                        )
                      else
                        Text(
                          displayName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF2D2D2D),
                          ),
                        ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFFFFB000,
                          ).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          userRoleLabel,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFFFFB000),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildDrawerItem(
                  icon: Icons.space_dashboard_outlined,
                  title: 'Accueil',
                  isActive: true,
                  onTap: () => Navigator.pop(context),
                ),
                _buildDrawerItem(
                  icon: Icons.assignment_turned_in_outlined,
                  title: 'Candidatures',
                  badgeCount: 3,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/freelance/applications');
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.chat_bubble_outline_rounded,
                  title: 'Messages',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/freelance/chat-list');
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.account_circle_outlined,
                  title: 'Mon Profil',
                  onTap: () async {
                    Navigator.pop(context);

                    final fallbackId = widget.authController?.currentUser?.id;
                    final userId = fallbackId != null && fallbackId > 0
                        ? fallbackId.toString()
                        : 'me';

                    await Navigator.pushNamed(
                      context,
                      '/freelance/profile',
                      arguments: {
                        'userId': userId,
                        'authController': widget.authController,
                      },
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'Portefeuille & Factures',
                  onTap: () {},
                ),
                _buildDrawerItem(
                  icon: Icons.tune_rounded,
                  title: 'Paramètres',
                  onTap: () {},
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.logout_rounded,
                      color: Colors.red[700],
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Déconnexion',
                      style: TextStyle(
                        color: Colors.red[700],
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    bool isActive = false,
    int badgeCount = 0,
    required VoidCallback onTap,
  }) {
    final activeColor = const Color(0xFFFFB000);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        tileColor: isActive
            ? activeColor.withValues(alpha: 0.08)
            : Colors.transparent,
        leading: Icon(icon, color: isActive ? activeColor : Colors.black54),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
            color: isActive ? activeColor : Colors.black87,
            fontSize: 15,
          ),
        ),
        trailing: badgeCount > 0
            ? Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: activeColor,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$badgeCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}

class _MissionCard extends StatelessWidget {
  const _MissionCard({
    required this.title,
    required this.description,
    required this.budget,
    required this.tags,
    required this.onTap,
    this.clientName,
    this.duration,
  });

  final String title;
  final String description;
  final String budget;
  final List<String> tags;
  final VoidCallback onTap;
  final String? clientName;
  final String? duration;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 140,
                  width: double.infinity,
                  color: const Color(0xFFFFD15C),
                  child: const Center(
                    child: Icon(
                      Icons.palette_outlined,
                      size: 45,
                      color: Colors.white,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF2D2D2D),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: tags
                            .map(
                              (tag) => Text(
                                tag,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black45,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                budget,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFFFFB000),
                                ),
                              ),
                              if (duration != null)
                                Text(
                                  duration!,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.black38,
                                  ),
                                ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFB000),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFFFFB000,
                                  ).withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Text(
                              'Voir la mission',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

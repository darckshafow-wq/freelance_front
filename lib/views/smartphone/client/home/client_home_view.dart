import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// Remonter de 4 niveaux pour aller chercher les contrôleurs et constantes
import '../../../../controllers/auth_controller.dart';
import '../../../../controllers/task_controller.dart';
import '../../../../constants/app_colors.dart';
import '../../../../models/task_model.dart';
import '../../../../services/api/mock_data.dart';
import '../../../../routes/app_router.dart';

// Remonter de 4 niveaux pour aller chercher les widgets partagés
import '../../../../views/shared/widgets/loading_indicator.dart';

class ClientHomeView extends StatefulWidget {
  final AuthController authController;

  const ClientHomeView({super.key, required this.authController});

  @override
  State<ClientHomeView> createState() => _ClientHomeViewState();
}

class _ClientHomeViewState extends State<ClientHomeView> {
  final TaskController _taskController = TaskController();

  // Index de l'onglet actif (0 = Accueil, 1 = Profil)
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _taskController.addListener(_onTaskStateChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _taskController.fetchTasks();
    });
  }

  @override
  void dispose() {
    _taskController.removeListener(_onTaskStateChanged);
    _taskController.dispose();
    super.dispose();
  }

  void _onTaskStateChanged() {
    if (mounted) setState(() {});
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return AppColors.warning;
      case TaskStatus.validated:
        return AppColors.success;
      case TaskStatus.executed:
        return AppColors.primary;
    }
  }

  String _getStatusLabel(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return 'En attente';
      case TaskStatus.validated:
        return 'Validé';
      case TaskStatus.executed:
        return 'Exécuté';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = widget.authController.currentUser;
    final userName = user?.fullName ?? 'Utilisateur';
    final userRole = user?.role.name.toUpperCase() ?? 'CLIENT';

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,

      // --- APPBAR NATIVE AVEC MENU HAMBURGER AUTOMATIQUE ---
      appBar: AppBar(
        automaticallyImplyLeading:
            true, // Laisse Flutter afficher l'icône de la Sidebar
        centerTitle: true,
        title: const Text(
          'Tableau de bord',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.colorScheme.onSurface,
        actions: [
          IconButton(
            onPressed: () async {
              await Navigator.pushNamed(context, AppRoutes.notifications);
              // Rafraîchir le badge après retour à l’écran
              if (mounted) setState(() {});
            },
            icon: Badge(
              isLabelVisible: MockData.getUnreadCount() > 0,
              label: Text(
                '${MockData.getUnreadCount()}',
                style: const TextStyle(fontSize: 10),
              ),
              backgroundColor: AppColors.error,
              child: const Icon(Icons.notifications_outlined, size: 26),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0, left: 8.0),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primary.withValues(alpha: 0.2),
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),

      // --- SIDEBAR (DRAWER) NATIVE ---
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: AppColors.primary),
              accountName: Text(
                userName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              accountEmail: Text(
                userRole,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard_outlined),
              title: const Text('Accueil'),
              selected: _currentIndex == 0,
              onTap: () {
                Navigator.pop(context); // Ferme la Sidebar
                setState(() => _currentIndex = 0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.assignment_outlined),
              title: const Text('Mes Missions Postées'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  '/tasks',
                  arguments: widget.authController,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Profil'),
              selected: _currentIndex == 1,
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  '/profile',
                  arguments: widget.authController,
                );
              },
            ),
            const Divider(),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text(
                'Déconnexion',
                style: TextStyle(color: Colors.redAccent),
              ),
              onTap: () async {
                Navigator.pop(context); // Ferme le drawer
                // Appel de ta logique de déconnexion si elle existe
                //await widget.authController.logout();
                if (mounted) {
                  // Nettoie l'historique de navigation et redirige vers le Login
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                }
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),

      // --- FLOATING ACTION BUTTON POUR CREER UNE MISSION ---
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/smartphone/client/missions/create_mission_view',
            arguments: widget.authController,
          );
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text(
          'Mission',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      // --- CORPS DE PAGE ---
      body: RefreshIndicator(
        onRefresh: () => _taskController.fetchTasks(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- HEADER STYLISÉ ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bonjour, $userName ',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          userRole,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // --- BARRE DE RECHERCHE RAPIDE ---
              TextField(
                decoration: InputDecoration(
                  hintText: 'Rechercher une mission...',
                  prefixIcon: const Icon(Icons.search, size: 22),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: theme.dividerColor.withValues(alpha: 0.05),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: theme.dividerColor.withValues(alpha: 0.1),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // --- CARTE GOOGLE MAPS (PLACEHOLDER) ---
              Text(
                'Missions à proximité',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: theme.colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: theme.shadowColor.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    // Placeholder pour GoogleMap API
                    const GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(5.366, -3.966), // Abidjan par défaut
                        zoom: 12,
                      ),
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                    ),
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.1),
                        child: const Center(
                          child: Text(
                            'Chargement de la carte...',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(blurRadius: 2, color: Colors.black),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // --- TITRE DE SECTION ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Missions Disponibles',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _taskController.fetchTasks(),
                    icon: const Icon(Icons.tune, size: 16),
                    label: const Text(
                      'Filtres',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // --- GESTION DES ÉTATS (CHARGEMENT / ERREUR / VIDE) ---
              if (_taskController.isLoading)
                const SizedBox(
                  height: 200,
                  child: LoadingIndicator(
                    message: 'Chargement des missions...',
                  ),
                )
              else if (_taskController.errorMessage != null)
                Card(
                  color: theme.colorScheme.error.withValues(alpha: 0.05),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Text(
                          _taskController.errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: theme.colorScheme.error),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () => _taskController.fetchTasks(),
                          icon: const Icon(Icons.replay, size: 16),
                          label: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  ),
                )
              else if (_taskController.tasks.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      Icon(
                        Icons.assignment_late_outlined,
                        size: 48,
                        color: theme.disabledColor,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Aucune mission disponible.',
                        style: TextStyle(
                          color: theme.disabledColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              else
                // --- LISTE DES CARTES ---
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _taskController.tasks.length,
                  itemBuilder: (context, index) {
                    final task = _taskController.tasks[index];
                    final statusColor = _getStatusColor(task.status);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 14),
                      elevation: 1,
                      shadowColor: theme.shadowColor.withValues(alpha: 0.05),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            left: BorderSide(color: statusColor, width: 4),
                          ),
                        ),
                        child: InkWell(
                          onTap: () {
                            // CORRECTION : Navigation dynamique vers les détails de la tâche
                            Navigator.pushNamed(
                              context,
                              '/smartphone/client/missions/mission_detail_view',
                              arguments: task
                                  .id, // On passe l'identifiant unique requis
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        task.title,
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: -0.2,
                                            ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: statusColor.withValues(
                                          alpha: 0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        _getStatusLabel(task.status),
                                        style: TextStyle(
                                          color: statusColor,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  task.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.6),
                                    height: 1.3,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Divider(
                                  color: theme.dividerColor.withValues(
                                    alpha: 0.05,
                                  ),
                                  height: 1,
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.account_balance_wallet_outlined,
                                          size: 18,
                                          color: AppColors.primary,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '${task.budget.toStringAsFixed(0)} F CFA',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 15,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (task.deadline != null)
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_today_outlined,
                                            size: 14,
                                            color: theme.hintColor,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${task.deadline!.day.toString().padLeft(2, '0')}/${task.deadline!.month.toString().padLeft(2, '0')}/${task.deadline!.year}',
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                                  color: theme.hintColor,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

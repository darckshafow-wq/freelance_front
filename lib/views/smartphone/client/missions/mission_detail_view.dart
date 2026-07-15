import 'package:flutter/material.dart';

// Remonter de 4 niveaux pour aller chercher les contrôleurs, constantes et modèles
import '../../../../controllers/client/task_controller.dart';
import '../../../../constants/app_colors.dart';
import '../../../../models/client/task_model.dart';
import '../../../shared/widgets/loading_indicator.dart';

class MissionDetailView extends StatefulWidget {
  final int taskId;

  const MissionDetailView({super.key, required this.taskId});

  @override
  State<MissionDetailView> createState() => _MissionDetailViewState();
}

class _MissionDetailViewState extends State<MissionDetailView> {
  final TaskController _taskController = TaskController();
  TaskModel? _task;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTaskDetails();
  }

  Future<void> _loadTaskDetails() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Simulation ou appel de récupération de la tâche spécifique via ton controller
      // Si ton controller n'a pas encore de méthode fetchTaskById, on cherche dans la liste existante :
      await _taskController.fetchTasks();

      final foundTask = _taskController.tasks.firstWhere(
        (t) => t.id == widget.taskId,
        orElse: () => throw Exception('Mission introuvable'),
      );

      if (mounted) {
        setState(() {
          _task = foundTask;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
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

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,

      // --- APP BAR ---
      appBar: AppBar(
        title: const Text(
          'Détails de la Mission',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.colorScheme.onSurface,
      ),

      // --- BODY SÉCURISÉ SELON LES ÉTATS ---
      body: _isLoading
          ? const Center(
              child: LoadingIndicator(message: 'Chargement des détails...'),
            )
          : _errorMessage != null
          ? _buildErrorWidget(theme)
          : _task == null
          ? const Center(child: Text('Aucune donnée trouvée.'))
          : _buildMainContent(theme),
    );
  }

  // --- ÉCRAN D'ERREUR ---
  Widget _buildErrorWidget(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.colorScheme.error, fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadTaskDetails,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  // --- CONTENU PRINCIPAL ---
  Widget _buildMainContent(ThemeData theme) {
    final statusColor = _getStatusColor(_task!.status);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête : Titre et Badge de Statut
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        _task!.title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getStatusLabel(_task!.status),
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Section 1 : Budget & Échéance (Métriques clés)
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        theme: theme,
                        icon: Icons.account_balance_wallet_outlined,
                        title: 'Budget Proposé',
                        value: '${_task!.budget.toStringAsFixed(0)} F CFA',
                        valueColor: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (_task!.deadline != null)
                      Expanded(
                        child: _buildMetricCard(
                          theme: theme,
                          icon: Icons.calendar_today_outlined,
                          title: 'Date Limite',
                          value:
                              '${_task!.deadline!.day.toString().padLeft(2, '0')}/${_task!.deadline!.month.toString().padLeft(2, '0')}/${_task!.deadline!.year}',
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),

                // Section 2 : Description de la mission
                Text(
                  'Description du projet',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  elevation: 0,
                  color: theme.colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: theme.dividerColor.withValues(alpha: 0.05),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: Text(
                        _task!.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.5,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // --- SECTION BASSE : BOUTON D'ACTION IMMOBILE ---
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: theme.cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            child: ElevatedButton(
              onPressed: () {
                // Action contextuelle (ex: Modifier la mission ou voir les candidatures reçues)
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Gérer les propositions',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Composant utilitaire pour générer des petites cartes d'infos (Budget / Date)
  Widget _buildMetricCard({
    required ThemeData theme,
    required IconData icon,
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: valueColor ?? theme.hintColor, size: 20),
          const SizedBox(height: 10),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: valueColor ?? theme.colorScheme.onSurface,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// freelance_profile_page.dart
// Page de profil du Freelance.
//
// Affiche :
//   - Informations de base (nom, email, téléphone)
//   - Statistiques chiffrées (missions, candidatures, taux de succès)
//   - Liste des candidatures avec leur statut
//   - Avis et commentaires reçus avec note et étoiles
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../constants/app_colors.dart';
import '../../../../models/auth/user_model.dart';
import '../../../../models/freelance/freelance_stats_model.dart';
import '../../../../models/freelance/application_model.dart';
import '../../../../models/shared/review_model.dart';
import '../../../../controllers/auth/auth_controller.dart';
import '../../../../controllers/freelance/profil_controller.dart';

class FreelanceProfilePage extends StatefulWidget {
  final String userId;
  final AuthController? authController;

  const FreelanceProfilePage({
    super.key,
    required this.userId,
    this.authController,
  });

  @override
  State<FreelanceProfilePage> createState() => _FreelanceProfilePageState();
}

class _FreelanceProfilePageState extends State<FreelanceProfilePage> {
  final ProfilController _controller = ProfilController();

  late Future<(UserModel?, FreelanceStatsModel)> _profileFuture;

  @override
  void initState() {
    super.initState();

    final currentUserId = ProfilController.resolveUserId(
      widget.userId,
      currentUserId: widget.authController?.currentUser?.id,
    );

    final resolvedUserId =
        currentUserId ?? widget.authController?.currentUser?.id;

    _profileFuture =
        Future.wait([
          _controller.getUserInfo(resolvedUserId ?? 0),
          _controller.loadFullProfile(userId: resolvedUserId ?? 0),
        ]).then(
          (results) =>
              (results[0] as UserModel?, results[1] as FreelanceStatsModel),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      body: FutureBuilder<(UserModel?, FreelanceStatsModel)>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _LoadingView();
          }

          if (snapshot.hasError) {
            return _ErrorView(error: snapshot.error.toString());
          }

          final user = snapshot.data?.$1;
          final stats = snapshot.data?.$2 ?? FreelanceStatsModel.empty();

          if (user == null &&
              stats.applications.isEmpty &&
              stats.reviews.isEmpty) {
            return const _EmptyProfileView();
          }

          return CustomScrollView(
            slivers: [
              // ── AppBar avec avatar et infos de base ──────────────────────
              _ProfileSliverAppBar(user: user),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Statistiques chiffrées ────────────────────────────
                      _StatsGrid(stats: stats),
                      const SizedBox(height: 24),

                      // ── Informations personnelles ─────────────────────────
                      if (user != null) ...[
                        _SectionTitle(
                          icon: Icons.person_outline_rounded,
                          title: 'Informations',
                        ),
                        const SizedBox(height: 12),
                        _InfoCard(user: user),
                        const SizedBox(height: 24),
                      ],

                      // ── Candidatures ──────────────────────────────────────
                      _SectionTitle(
                        icon: Icons.send_outlined,
                        title: 'Candidatures (${stats.applications.length})',
                      ),
                      const SizedBox(height: 12),
                      _ApplicationsList(applications: stats.applications),
                      const SizedBox(height: 24),

                      // ── Avis & Commentaires ───────────────────────────────
                      _SectionTitle(
                        icon: Icons.star_outline_rounded,
                        title: 'Avis reçus (${stats.reviews.length})',
                        trailing: stats.reviews.isNotEmpty
                            ? _RatingBadge(rating: stats.averageRating)
                            : null,
                      ),
                      const SizedBox(height: 12),
                      _ReviewsList(reviews: stats.reviews),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SliverAppBar avec avatar et nom du freelance
// ─────────────────────────────────────────────────────────────────────────────
class _ProfileSliverAppBar extends StatelessWidget {
  final UserModel? user;
  const _ProfileSliverAppBar({required this.user});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: const Color(0xFFFFB000),
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFB000), Color(0xFFFFD15C)],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Avatar
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2.5),
                  ),
                  child: CircleAvatar(
                    radius: 38,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    child: const Icon(
                      Icons.person_rounded,
                      size: 42,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  user?.fullName.isNotEmpty == true
                      ? user!.fullName
                      : 'Freelance',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  (user?.email ?? '').isNotEmpty
                      ? user!.email
                      : 'Profil freelance',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 12,
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

// ─────────────────────────────────────────────────────────────────────────────
// Grille de statistiques : 3 colonnes × 2 lignes
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyProfileView extends StatelessWidget {
  const _EmptyProfileView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.person_off_outlined,
              size: 56,
              color: Color(0xFFFFB000),
            ),
            const SizedBox(height: 12),
            const Text(
              'Impossible de charger le profil freelance.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2D2D2D),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Vérifiez votre connexion ou réessayez plus tard.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final FreelanceStatsModel stats;
  const _StatsGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    final items = [
      _StatItem(
        icon: Icons.check_circle_outline_rounded,
        label: 'Missions\nterminées',
        value: '${stats.tasksDone}',
        color: const Color(0xFF22C55E),
      ),
      _StatItem(
        icon: Icons.hourglass_top_rounded,
        label: 'En cours',
        value: '${stats.tasksInProgress}',
        color: const Color(0xFFF59E0B),
      ),
      _StatItem(
        icon: Icons.send_rounded,
        label: 'Candidatures\nenvoyées',
        value: '${stats.applicationsSent}',
        color: AppColors.accent,
      ),
      _StatItem(
        icon: Icons.thumb_up_alt_outlined,
        label: 'Acceptées',
        value: '${stats.applicationsAccepted}',
        color: const Color(0xFF3B82F6),
      ),
      _StatItem(
        icon: Icons.thumb_down_alt_outlined,
        label: 'Refusées',
        value: '${stats.applicationsRejected}',
        color: const Color(0xFFEF4444),
      ),
      _StatItem(
        icon: Icons.trending_up_rounded,
        label: 'Taux de\nsuccès',
        value: '${stats.successRate}%',
        color: const Color(0xFF8B5CF6),
      ),
    ];

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.0,
      children: items.map((item) => _StatCard(item: item)).toList(),
    );
  }
}

class _StatItem {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
}

class _StatCard extends StatelessWidget {
  final _StatItem item;
  const _StatCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(item.icon, color: item.color, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            item.value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: item.color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            item.label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Carte d'informations personnelles
// ─────────────────────────────────────────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  final UserModel user;
  const _InfoCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.badge_outlined,
            label: 'Nom / Pseudo',
            value: user.fullName.isNotEmpty ? user.fullName : '—',
          ),
          const Divider(height: 1, indent: 56),
          _InfoRow(
            icon: Icons.email_outlined,
            label: 'Email',
            value: user.email,
          ),
          if (user.phoneNumber != null) ...[
            const Divider(height: 1, indent: 56),
            _InfoRow(
              icon: Icons.phone_outlined,
              label: 'Téléphone',
              value: user.phoneNumber!,
            ),
          ],
          const Divider(height: 1, indent: 56),
          _InfoRow(
            icon: Icons.verified_outlined,
            label: 'Statut',
            value: user.isVerified ? 'Vérifié ✓' : 'Non vérifié',
            valueColor: user.isVerified ? const Color(0xFF22C55E) : Colors.grey,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 22, color: Colors.grey),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF555555), fontSize: 14),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section Candidatures
// ─────────────────────────────────────────────────────────────────────────────
class _ApplicationsList extends StatelessWidget {
  final List<ApplicationModel> applications;
  const _ApplicationsList({required this.applications});

  @override
  Widget build(BuildContext context) {
    if (applications.isEmpty) {
      return _EmptyState(
        icon: Icons.inbox_outlined,
        message: 'Aucune candidature pour le moment',
      );
    }

    return Column(
      children: applications
          .map((app) => _ApplicationTile(application: app))
          .toList(),
    );
  }
}

class _ApplicationTile extends StatelessWidget {
  final ApplicationModel application;
  const _ApplicationTile({required this.application});

  Color get _statusColor {
    switch (application.status) {
      case ApplicationStatus.accepted:
        return const Color(0xFF22C55E);
      case ApplicationStatus.rejected:
        return const Color(0xFFEF4444);
      case ApplicationStatus.pending:
        return const Color(0xFFF59E0B);
    }
  }

  String get _statusLabel {
    switch (application.status) {
      case ApplicationStatus.accepted:
        return 'Acceptée';
      case ApplicationStatus.rejected:
        return 'Refusée';
      case ApplicationStatus.pending:
        return 'En attente';
    }
  }

  IconData get _statusIcon {
    switch (application.status) {
      case ApplicationStatus.accepted:
        return Icons.check_circle_rounded;
      case ApplicationStatus.rejected:
        return Icons.cancel_rounded;
      case ApplicationStatus.pending:
        return Icons.pending_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _statusColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icône statut
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _statusColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(_statusIcon, color: _statusColor, size: 18),
          ),
          const SizedBox(width: 12),
          // Détails
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mission #${application.taskId}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  application.coverLetter.isNotEmpty
                      ? application.coverLetter
                      : 'Candidature envoyée',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Budget proposé
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _statusLabel,
                  style: TextStyle(
                    color: _statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${application.proposedBudget.toStringAsFixed(0)} €',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D2D2D),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section Avis / Commentaires
// ─────────────────────────────────────────────────────────────────────────────
class _ReviewsList extends StatelessWidget {
  final List<ReviewModel> reviews;
  const _ReviewsList({required this.reviews});

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
      return _EmptyState(
        icon: Icons.rate_review_outlined,
        message: 'Aucun avis reçu pour le moment',
      );
    }

    return Column(
      children: reviews.map((r) => _ReviewTile(review: r)).toList(),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final ReviewModel review;
  const _ReviewTile({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête : mission + étoiles
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mission #${review.taskId}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Color(0xFF2D2D2D),
                ),
              ),
              _StarRating(rating: review.rating),
            ],
          ),
          const SizedBox(height: 8),
          // Commentaire
          Text(
            review.comment.isNotEmpty
                ? '"${review.comment}"'
                : 'Aucun commentaire',
            style: const TextStyle(
              color: Color(0xFF555555),
              fontSize: 13,
              fontStyle: FontStyle.italic,
            ),
          ),
          // Date
          if (review.createdAt != null) ...[
            const SizedBox(height: 6),
            Text(
              _formatDate(review.createdAt!),
              style: const TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widget : étoiles de notation
// ─────────────────────────────────────────────────────────────────────────────
class _StarRating extends StatelessWidget {
  final double rating;
  const _StarRating({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < rating.floor();
        final half = !filled && i < rating;
        return Icon(
          filled
              ? Icons.star_rounded
              : half
              ? Icons.star_half_rounded
              : Icons.star_outline_rounded,
          color: const Color(0xFFF59E0B),
          size: 16,
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Badge note moyenne
// ─────────────────────────────────────────────────────────────────────────────
class _RatingBadge extends StatelessWidget {
  final double rating;
  const _RatingBadge({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 14),
          const SizedBox(width: 4),
          Text(
            rating.toString(),
            style: const TextStyle(
              color: Color(0xFFF59E0B),
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Titre de section avec icône
// ─────────────────────────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;

  const _SectionTitle({required this.icon, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D2D2D),
            ),
          ),
        ),
        ?trailing,
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// État vide (liste vide)
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: Colors.grey.shade300),
          const SizedBox(height: 10),
          Text(
            message,
            style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Vue de chargement
// ─────────────────────────────────────────────────────────────────────────────
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.accent),
            const SizedBox(height: 16),
            const Text(
              'Chargement du profil...',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Vue d'erreur
// ─────────────────────────────────────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  final String error;
  const _ErrorView({required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 56,
                color: Color(0xFFEF4444),
              ),
              const SizedBox(height: 16),
              const Text(
                'Impossible de charger le profil',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Retour'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

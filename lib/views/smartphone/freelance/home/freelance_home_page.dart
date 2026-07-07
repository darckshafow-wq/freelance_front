import 'package:flutter/material.dart';
import '../../../../constants/app_colors.dart';
import '../../../../services/api/mock_data.dart';
import '../../../../routes/app_router.dart';

class FreelanceHomePage extends StatelessWidget {
  const FreelanceHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7), // Fond beige très clair
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
              await Navigator.pushNamed(context, AppRoutes.notifications);
            },
            icon: Badge(
              isLabelVisible: MockData.getUnreadCount() > 0,
              label: Text(
                '${MockData.getUnreadCount()}',
                style: const TextStyle(fontSize: 10),
              ),
              backgroundColor: AppColors.error,
              child: const Icon(Icons.notifications_outlined),
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

              _MissionCard(
                title: 'Landing page moderne',
                description:
                    'Conception d\'une interface épurée et réactive avec animations fluides pour une startup FinTech.',
                budget: '800 €',
                clientName: 'TechStart Studio',
                duration: '10 jours',
                tags: const ['UI/UX', 'Remote', 'Urgent', 'Figma'],
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/freelance/job-detail',
                    arguments: {
                      'title': 'Landing page moderne',
                      'budget': '800 €',
                      'clientName': 'TechStart Studio',
                      'duration': '10 jours',
                      'description':
                          'Nous recherchons un développeur Front-End pour concevoir et intégrer la nouvelle landing page de notre solution FinTech. Le design Figma est déjà finalisé — votre rôle sera de lui donner vie avec des animations fluides.',
                      'tags': ['UI/UX', 'Remote', 'Urgent', 'Figma'],
                    },
                  );
                },
              ),
              const SizedBox(height: 24),
              _MissionCard(
                title: 'Refonte mobile UI',
                description:
                    'Amélioration de l\'expérience utilisateur globale sur une application de livraison e-commerce existante.',
                budget: '1 200 €',
                clientName: 'DeliverX',
                duration: '21 jours',
                tags: const ['Flutter', 'Design system', 'Mobile'],
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/freelance/job-detail',
                    arguments: {
                      'title': 'Refonte mobile UI',
                      'budget': '1 200 €',
                      'clientName': 'DeliverX',
                      'duration': '21 jours',
                      'description':
                          'Amélioration de l\'expérience utilisateur globale sur une application de livraison e-commerce existante. Design system à respecter, composants à refactoriser.',
                      'tags': ['Flutter', 'Design system', 'Mobile'],
                    },
                  );
                },
              ),
              const SizedBox(height: 24),
              _MissionCard(
                title: 'Audit sécurité Cloud AWS',
                description:
                    'Audit complet de la configuration AWS, politiques IAM et bases de données. Livraison d\'un rapport de vulnérabilités.',
                budget: '4 000 €',
                clientName: 'SecureOps',
                duration: '14 jours',
                tags: const ['AWS', 'Sécurité', 'DevOps'],
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/freelance/job-detail',
                    arguments: {
                      'title': 'Audit sécurité Cloud AWS',
                      'budget': '4 000 €',
                      'clientName': 'SecureOps',
                      'duration': '14 jours',
                      'description':
                          'Audit complet de la configuration AWS, politiques IAM et bases de données MySQL. Fournir un rapport détaillé des vulnérabilités avec recommandations correctives.',
                      'tags': ['AWS', 'Sécurité', 'DevOps'],
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

  // --- NOUVELLE SIDEBAR (DRAWER) AMÉLIORÉE ---
  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      // Donne un effet arrondi unique au tiroir sur le côté droit
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          // En-tête personnalisé et moderne (Plus propre que UserAccountsDrawerHeader)
          Container(
            padding: const EdgeInsets.only(
              top: 60,
              left: 24,
              right: 24,
              bottom: 24,
            ),
            color: const Color(0xFFFDFBF7), // Match avec le fond de l'app
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
                      const Text(
                        'John Doe',
                        style: TextStyle(
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
                          color: const Color(0xFFFFB000).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Freelance Vérifié',
                          style: TextStyle(
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

          // Corps du menu
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildDrawerItem(
                  icon: Icons.space_dashboard_outlined,
                  title: 'Accueil',
                  isActive: true, // Item sélectionné
                  onTap: () => Navigator.pop(context),
                ),
                _buildDrawerItem(
                  icon: Icons.assignment_turned_in_outlined,
                  title: 'Candidatures',
                  badgeCount: 3, // Badge de notification ajouté
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/freelance/applications');
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.account_circle_outlined,
                  title: 'Mon Profil',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/freelance/profile');
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

          // Bas de la Sidebar (Zone Déconnexion isolée)
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

  // Helper pour concevoir des lignes de menu épurées rapidement
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

// Carte de mission affichée sur la page d'accueil freelance
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
                              const Text(
                                '+ validation rapide',
                                style: TextStyle(
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

import 'package:flutter/material.dart';

class FreelanceJobDetailPage extends StatelessWidget {
  const FreelanceJobDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Récupération dynamique des données passées via les arguments de navigation
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final String title = args?['title'] ?? 'Landing page moderne';
    final String budget = args?['budget'] ?? '800 €';
    final String clientName = args?['clientName'] ?? 'TechStart Studio';
    final String duration = args?['duration'] ?? '10 jours';
    final String description =
        args?['description'] ??
        'Nous recherchons un développeur Full-Stack ou Front-End talentueux pour concevoir et intégrer '
            'la nouvelle landing page de notre solution FinTech.\n\n'
            'Le design Figma est déjà entièrement finalisé et propre. Votre rôle sera de donner vie '
            'à cette maquette avec des animations fluides.';
    final List<String> tags = List<String>.from(
      args?['tags'] ?? ['UI/UX', 'Remote', 'Urgent', 'Figma'],
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      body: Stack(
        children: [
          // ─── Contenu défilant ────────────────────────────────────────────
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bannière haute avec icône
                Container(
                  height: 260,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFD15C),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.palette_outlined,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                ),

                // Corps des détails
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nom du client / entreprise
                      Text(
                        clientName.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFFFB000),
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Titre de la mission
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF2D2D2D),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Tags / Badges
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: tags
                            .map(
                              (tag) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    // Correction : withOpacity déprécié → withValues
                                    color: Colors.black.withValues(alpha: 0.05),
                                  ),
                                ),
                                child: Text(
                                  tag,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 28),

                      // Section Rémunération + Bouton Postuler
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            // Correction : withOpacity déprécié → withValues
                            color: Colors.black.withValues(alpha: 0.04),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Rémunération',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black38,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      budget,
                                      style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFFFFB000),
                                      ),
                                    ),
                                  ],
                                ),
                                // Badge durée
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    // Correction : withOpacity → withValues
                                    color: const Color(
                                      0xFFFFB000,
                                    ).withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '⏱ $duration',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFFFB000),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Bouton Postuler
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          const Icon(
                                            Icons.check_circle_outline,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              'Votre candidature pour "$title" a été envoyée !',
                                            ),
                                          ),
                                        ],
                                      ),
                                      backgroundColor: const Color(0xFFFFB000),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      margin: const EdgeInsets.all(16),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFB000),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Postuler',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(Icons.arrow_forward_rounded, size: 18),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Section Description
                      const Text(
                        'Description du projet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF2D2D2D),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[700],
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ─── Bouton Retour flottant (dans SafeArea pour éviter la status bar) ──
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 8, left: 16),
              child: ClipOval(
                child: Material(
                  // Correction : withOpacity → withValues
                  color: Colors.white.withValues(alpha: 0.92),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Color(0xFF2D2D2D),
                      size: 20,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

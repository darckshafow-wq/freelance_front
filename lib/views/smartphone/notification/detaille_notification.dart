import 'package:flutter/material.dart';
import '../../../../models/shared/notification_model.dart';

// ─── Palette FreelancePage ────────────────────────────────────────────────────
const Color _kBg = Color(0xFFFDFBF7);
const Color _kAmber = Color(0xFFFFB000);
const Color _kAmberLight = Color(0xFFFFD15C);
const Color _kDark = Color(0xFF2D2D2D);
const Color _kRed = Color(0xFFFF4757);
const Color _kGreen = Color(0xFF2ED573);

class DetailleNotificationView extends StatelessWidget {
  const DetailleNotificationView({super.key});

  _NotifMeta _metaFor(NotificationType type) {
    switch (type) {
      case NotificationType.newApplication:
        return _NotifMeta(
          Icons.person_add_outlined,
          _kAmber,
          'Candidature reçue',
        );
      case NotificationType.applicationAccepted:
        return _NotifMeta(
          Icons.check_circle_outline,
          _kGreen,
          'Candidature acceptée',
        );
      case NotificationType.applicationRejected:
        return _NotifMeta(Icons.cancel_outlined, _kRed, 'Candidature refusée');
      case NotificationType.missionValidated:
        return _NotifMeta(Icons.verified_outlined, _kAmber, 'Mission validée');
      case NotificationType.missionCompleted:
        return _NotifMeta(
          Icons.flag_outlined,
          _kAmberLight,
          'Mission terminée',
        );
      case NotificationType.newMessage:
        return _NotifMeta(
          Icons.chat_bubble_outline,
          _kAmber,
          'Nouveau message',
        );
      case NotificationType.paymentReceived:
        return _NotifMeta(
          Icons.account_balance_wallet_outlined,
          _kGreen,
          'Paiement reçu',
        );
      case NotificationType.system:
        return _NotifMeta(
          Icons.info_outline,
          const Color(0xFF8D8D8D),
          'Notification système',
        );
    }
  }

  String _formatDate(DateTime dt) {
    final months = [
      'jan.',
      'fév.',
      'mar.',
      'avr.',
      'mai',
      'juin',
      'juil.',
      'août',
      'sep.',
      'oct.',
      'nov.',
      'déc.',
    ];
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${months[dt.month - 1]} ${dt.year} à $hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    final notif =
        ModalRoute.of(context)?.settings.arguments as NotificationModel?;

    if (notif == null) {
      return Scaffold(
        backgroundColor: _kBg,
        appBar: AppBar(
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: _kDark),
          title: const Text(
            'Notification',
            style: TextStyle(color: _kDark, fontWeight: FontWeight.w800),
          ),
          elevation: 0,
        ),
        body: const Center(child: Text('Notification introuvable.')),
      );
    }

    final meta = _metaFor(notif.type);

    return Scaffold(
      backgroundColor: _kBg,

      // ── AppBar style FreelancePage ──────────────────────────────────────
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: _kDark),
        centerTitle: false,
        title: const Text(
          'Détail',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: _kDark,
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Bannière haute style FreelancePage ──────────────────────────
            Container(
              height: 200,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: _kAmberLight,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.35),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(meta.icon, color: Colors.white, size: 36),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.30),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      meta.label.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Corps ───────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_outlined,
                        size: 14,
                        color: Colors.black38,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _formatDate(notif.createdAt),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black38,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Titre
                  Text(
                    notif.title,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: _kDark,
                      letterSpacing: -0.5,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Carte corps
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
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
                    child: Text(
                      notif.body,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[700],
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Bouton d'action si route disponible
                  if (notif.actionRoute != null) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pushNamedAndRemoveUntil(
                          context,
                          notif.actionRoute!,
                          (route) => route.isFirst,
                          arguments: notif.relatedId,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _kAmber,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          shadowColor: _kAmber.withValues(alpha: 0.3),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Voir la ressource liée',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded, size: 18),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Bouton retour
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: Colors.black.withValues(alpha: 0.10),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Retour',
                        style: TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotifMeta {
  final IconData icon;
  final Color color;
  final String label;
  const _NotifMeta(this.icon, this.color, this.label);
}

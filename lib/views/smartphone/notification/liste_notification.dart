import 'package:flutter/material.dart';
import '../../../../controllers/auth/auth_controller.dart';
import '../../../../controllers/shared/notification_controller.dart';
import '../../../../models/shared/notification_model.dart';

// ─── Palette FreelancePage ────────────────────────────────────────────────────
const Color _kBg = Color(0xFFFDFBF7);
const Color _kAmber = Color(0xFFFFB000);
const Color _kAmberLight = Color(0xFFFFD15C);
const Color _kDark = Color(0xFF2D2D2D);
const Color _kRed = Color(0xFFFF4757);
const Color _kGreen = Color(0xFF2ED573);

class ListeNotificationView extends StatefulWidget {
  final AuthController? authController;

  const ListeNotificationView({super.key, this.authController});

  @override
  State<ListeNotificationView> createState() => _ListeNotificationViewState();
}

class _ListeNotificationViewState extends State<ListeNotificationView>
    with SingleTickerProviderStateMixin {
  late final NotificationController _ctrl;
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _ctrl = NotificationController(
      role: widget.authController?.currentUser?.role,
    );
    _tabCtrl = TabController(length: 2, vsync: this);
    _ctrl.addListener(_refresh);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _ctrl.fetchNotifications(),
    );
  }

  @override
  void dispose() {
    _ctrl.removeListener(_refresh);
    _ctrl.dispose();
    _tabCtrl.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  // ─── Style icône/couleur selon type ─────────────────────────────────────
  _NotifMeta _metaFor(NotificationType type) {
    switch (type) {
      case NotificationType.newApplication:
        return _NotifMeta(Icons.person_add_outlined, _kAmber, 'Candidature');
      case NotificationType.applicationAccepted:
        return _NotifMeta(Icons.check_circle_outline, _kGreen, 'Acceptée');
      case NotificationType.applicationRejected:
        return _NotifMeta(Icons.cancel_outlined, _kRed, 'Refusée');
      case NotificationType.missionValidated:
        return _NotifMeta(Icons.verified_outlined, _kAmber, 'Mission validée');
      case NotificationType.missionCompleted:
        return _NotifMeta(Icons.flag_outlined, _kAmberLight, 'Terminée');
      case NotificationType.newMessage:
        return _NotifMeta(Icons.chat_bubble_outline, _kAmber, 'Message');
      case NotificationType.paymentReceived:
        return _NotifMeta(
          Icons.account_balance_wallet_outlined,
          _kGreen,
          'Paiement',
        );
      case NotificationType.system:
        return _NotifMeta(
          Icons.info_outline,
          const Color(0xFF8D8D8D),
          'Système',
        );
    }
  }

  String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours} h';
    if (diff.inDays == 1) return 'Hier';
    return 'Il y a ${diff.inDays} j';
  }

  // ─── Tuile ───────────────────────────────────────────────────────────────
  Widget _buildTile(NotificationModel notif) {
    final meta = _metaFor(notif.type);

    return Dismissible(
      key: Key('n-${notif.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: _kRed.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Icon(Icons.delete_outline, color: _kRed, size: 26),
      ),
      onDismissed: (_) => _ctrl.deleteNotification(notif.id),
      child: GestureDetector(
        onTap: () {
          _ctrl.markAsRead(notif.id);
          Navigator.pushNamed(
            context,
            '/notifications/detail',
            arguments: notif,
          );
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: notif.isRead
                  ? Colors.transparent
                  : _kAmber.withValues(alpha: 0.35),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: notif.isRead ? 0.03 : 0.06,
                ),
                blurRadius: notif.isRead ? 8 : 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icône
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: meta.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(meta.icon, color: meta.color, size: 24),
                ),
                const SizedBox(width: 14),
                // Contenu
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Badge type
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: meta.color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              meta.label,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: meta.color,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                          const Spacer(),
                          // Point non-lu
                          if (!notif.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: _kAmber,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        notif.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: notif.isRead
                              ? FontWeight.w500
                              : FontWeight.w800,
                          color: _kDark,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notif.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _relativeTime(notif.createdAt),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.black38,
                          fontWeight: FontWeight.w500,
                        ),
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

  // ─── Liste vide ──────────────────────────────────────────────────────────
  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _kAmber.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_none_outlined,
              size: 40,
              color: _kAmber,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Aucune notification',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _kDark,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tout est à jour !',
            style: TextStyle(fontSize: 13, color: Colors.black38),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final unread = _ctrl.unreadCount;

    return Scaffold(
      backgroundColor: _kBg,

      // ── AppBar style FreelancePage ────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: _kDark),
        centerTitle: false,
        title: Row(
          children: [
            const Text(
              'Notifications',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: _kDark,
              ),
            ),
            if (unread > 0) ...[
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: _kAmber,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$unread',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (unread > 0)
            TextButton(
              onPressed: _ctrl.markAllAsRead,
              child: const Text(
                'Tout lire',
                style: TextStyle(
                  color: _kAmber,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: TabBar(
            controller: _tabCtrl,
            labelColor: _kAmber,
            unselectedLabelColor: Colors.black45,
            indicatorColor: _kAmber,
            indicatorWeight: 2.5,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
            tabs: [
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Non lues'),
                    if (unread > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _kAmber.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$unread',
                          style: const TextStyle(
                            color: _kAmber,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Tab(text: 'Toutes'),
            ],
          ),
        ),
      ),

      body: _ctrl.isLoading
          ? const Center(child: CircularProgressIndicator(color: _kAmber))
          : _ctrl.errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.wifi_off_outlined,
                    size: 48,
                    color: Colors.black26,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _ctrl.errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _ctrl.fetchNotifications,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Réessayer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kAmber,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              color: _kAmber,
              backgroundColor: Colors.white,
              onRefresh: _ctrl.fetchNotifications,
              child: TabBarView(
                controller: _tabCtrl,
                children: [
                  // Onglet Non lues
                  _ctrl.unread.isEmpty
                      ? _buildEmpty()
                      : ListView.builder(
                          padding: const EdgeInsets.only(top: 12, bottom: 32),
                          itemCount: _ctrl.unread.length,
                          itemBuilder: (_, i) => _buildTile(_ctrl.unread[i]),
                        ),
                  // Onglet Toutes
                  _ctrl.notifications.isEmpty
                      ? _buildEmpty()
                      : ListView.builder(
                          padding: const EdgeInsets.only(top: 12, bottom: 32),
                          itemCount: _ctrl.notifications.length,
                          itemBuilder: (_, i) =>
                              _buildTile(_ctrl.notifications[i]),
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

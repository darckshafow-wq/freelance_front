import 'package:flutter/material.dart';
import '../../../../controllers/auth/auth_controller.dart';
import '../../../../controllers/shared/notification_controller.dart';
import '../../../../models/shared/notification_model.dart';
import '../../../../constants/app_colors.dart';

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
        return _NotifMeta(
          Icons.person_add_rounded,
          AppColors.primary,
          'Candidature',
        );
      case NotificationType.applicationAccepted:
        return _NotifMeta(Icons.check_circle_rounded, Colors.green, 'Acceptée');
      case NotificationType.applicationRejected:
        return _NotifMeta(Icons.cancel_rounded, Colors.redAccent, 'Refusée');
      case NotificationType.missionValidated:
        return _NotifMeta(
          Icons.verified_rounded,
          AppColors.primary,
          'Mission validée',
        );
      case NotificationType.missionCompleted:
        return _NotifMeta(Icons.flag_rounded, Colors.blue, 'Terminée');
      case NotificationType.newMessage:
        return _NotifMeta(
          Icons.chat_bubble_rounded,
          AppColors.primary,
          'Message',
        );
      case NotificationType.paymentReceived:
        return _NotifMeta(
          Icons.account_balance_wallet_rounded,
          Colors.green,
          'Paiement',
        );
      case NotificationType.system:
        return _NotifMeta(
          Icons.info_rounded,
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
    return '${dt.day}/${dt.month}';
  }

  Widget _buildTile(NotificationModel notif) {
    final meta = _metaFor(notif.type);

    return Dismissible(
      key: Key('n-${notif.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.only(right: 25),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Icon(
          Icons.delete_sweep_rounded,
          color: Colors.redAccent,
          size: 28,
        ),
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
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: notif.isRead
                  ? Colors.grey[100]!
                  : AppColors.primary.withValues(alpha: 0.3),
              width: notif.isRead ? 1 : 2,
            ),
            boxShadow: [
              if (!notif.isRead)
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: notif.isRead ? Colors.grey[50] : Colors.black,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  meta.icon,
                  color: notif.isRead ? Colors.black38 : AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: notif.isRead
                                ? Colors.grey[100]
                                : AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            meta.label.toUpperCase(),
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: notif.isRead
                                  ? Colors.grey[400]
                                  : (meta.color == AppColors.primary
                                        ? Colors.black54
                                        : meta.color),
                            ),
                          ),
                        ),
                        Text(
                          _relativeTime(notif.createdAt),
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[400],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      notif.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: notif.isRead
                            ? FontWeight.w700
                            : FontWeight.w900,
                        color: notif.isRead ? Colors.black54 : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notif.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: notif.isRead
                            ? Colors.grey[400]
                            : Colors.grey[600],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              if (!notif.isRead)
                Container(
                  margin: const EdgeInsets.only(left: 10, top: 25),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_off_rounded,
              size: 45,
              color: Colors.grey[300],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Aucune notification',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Revenez plus tard pour les nouveautés',
            style: TextStyle(
              color: Colors.grey[400],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final unread = _ctrl.unreadCount;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Colors.black,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          if (unread > 0)
            TextButton(
              onPressed: _ctrl.markAllAsRead,
              child: const Text(
                'Tout lire',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(15),
            ),
            child: TabBar(
              controller: _tabCtrl,
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 13,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
              tabs: [
                Tab(text: unread > 0 ? 'Non lues ($unread)' : 'Non lues'),
                const Tab(text: 'Toutes'),
              ],
            ),
          ),
        ),
      ),
      body: _ctrl.isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : RefreshIndicator(
              color: Colors.black,
              backgroundColor: AppColors.primary,
              onRefresh: _ctrl.fetchNotifications,
              child: TabBarView(
                controller: _tabCtrl,
                children: [
                  _ctrl.unread.isEmpty
                      ? _buildEmpty()
                      : ListView.builder(
                          padding: const EdgeInsets.only(top: 10, bottom: 30),
                          itemCount: _ctrl.unread.length,
                          itemBuilder: (_, i) => _buildTile(_ctrl.unread[i]),
                        ),
                  _ctrl.notifications.isEmpty
                      ? _buildEmpty()
                      : ListView.builder(
                          padding: const EdgeInsets.only(top: 10, bottom: 30),
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

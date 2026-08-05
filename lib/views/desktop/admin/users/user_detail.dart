import 'package:flutter/material.dart';
import '../../../../constants/app_colors.dart';
import '../../../../controllers/admin/admin_controller.dart';
import '../../../../models/auth/user_model.dart';
import '../../../shared/widgets/admin_desktop_scaffold.dart';

class AdminUserDetail extends StatefulWidget {
  final int userId;
  const AdminUserDetail({super.key, required this.userId});

  @override
  State<AdminUserDetail> createState() => _AdminUserDetailState();
}

class _AdminUserDetailState extends State<AdminUserDetail> {
  final AdminController _controller = AdminController();
  UserModel? _user;
  bool _localLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _controller.fetchUsers();
    if (mounted) {
      setState(() {
        _user = _controller.users.firstWhere(
          (u) => u.id == widget.userId,
          orElse: () => _controller.users.first,
        );
        _localLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_localLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }
    if (_user == null) {
      return const AdminDesktopScaffold(
        selectedIndex: 1,
        title: 'User Profile',
        body: Center(child: Text('Utilisateur non trouvé')),
      );
    }

    return AdminDesktopScaffold(
      selectedIndex: 1,
      title: 'Profil Utilisateur #${_user!.id}',
      actions: [
        IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ],
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Profile Image
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                const CircleAvatar(
                  radius: 70,
                  backgroundColor: Colors.black,
                  child: Icon(
                    Icons.person_rounded,
                    color: AppColors.primary,
                    size: 70,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _user!.isVerified ? Colors.green : Colors.grey,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: Icon(
                    _user!.isVerified ? Icons.check : Icons.hourglass_empty,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
            Text(
              _user!.fullName,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            Text(
              _user!.role.name.toUpperCase(),
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 40),

            // Stats Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSimpleStat('85%', 'Taux de réussite'),
                const SizedBox(width: 40),
                _buildDivider(),
                const SizedBox(width: 40),
                _buildSimpleStat('4.8', 'Note moyenne'),
                const SizedBox(width: 40),
                _buildDivider(),
                const SizedBox(width: 40),
                _buildSimpleStat(
                  _user!.createdAt != null
                      ? '${DateTime.now().difference(_user!.createdAt!).inDays} j'
                      : 'N/A',
                  'Ancienneté',
                ),
              ],
            ),

            const SizedBox(height: 50),
            // Info Grid for Desktop
            LayoutBuilder(
              builder: (context, constraints) {
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: constraints.maxWidth > 800 ? 2 : 1,
                  childAspectRatio: 4,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  children: [
                    _buildInfoTile(Icons.email_rounded, 'Email', _user!.email),
                    _buildInfoTile(
                      Icons.phone_rounded,
                      'Téléphone',
                      _user!.phoneNumber ?? 'Non renseigné',
                    ),
                    _buildInfoTile(
                      Icons.verified_user_rounded,
                      'Statut de Vérification',
                      _user!.isVerified ? 'Vérifié' : 'En attente',
                    ),
                    _buildInfoTile(
                      Icons.calendar_today_rounded,
                      'Inscrit le',
                      _user!.createdAt?.toString().split(' ')[0] ?? 'N/A',
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 60),

            // Tabs for Tasks, Applications, Reviews
            _buildUserActivityTabs(),

            const SizedBox(height: 30),
            if (!_user!.isVerified)
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final success = await _controller.verifyUser(_user!.id);
                    if (!mounted) return;
                    if (success) {
                      setState(() {
                        _user = UserModel(
                          id: _user!.id,
                          email: _user!.email,
                          fullName: _user!.fullName,
                          role: _user!.role,
                          phoneNumber: _user!.phoneNumber,
                          location: _user!.location,
                          createdAt: _user!.createdAt,
                          isActive: _user!.isActive,
                          isClient: _user!.isClient,
                          isFreelancer: _user!.isFreelancer,
                          isAdmin: _user!.isAdmin,
                          isVerified: true,
                        );
                      });
                      if (!mounted) return;
                      final currentContext = context;
                      if (!currentContext.mounted) return;
                      ScaffoldMessenger.of(currentContext).showSnackBar(
                        const SnackBar(
                          content: Text('Utilisateur vérifié avec succès.'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.verified_user_rounded, size: 20),
                  label: const Text('Valider cet utilisateur'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 30),
            // Danger Zone
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Zone de danger',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Ces actions sont irréversibles. Soyez prudent.',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 65,
                    child: OutlinedButton(
                      onPressed: () async {
                        final success = await _controller.deleteUser(_user!.id);
                        if (success && context.mounted) Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'Suspendre / Supprimer le compte',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(height: 40, width: 1.5, color: Colors.white10);
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF14142B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserActivityTabs() {
    return DefaultTabController(
      length: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: 'Missions'),
              Tab(text: 'Candidatures'),
              Tab(text: 'Avis'),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 300,
            child: TabBarView(
              children: [
                _buildMockList('Aucune mission récente'),
                _buildMockList('Aucune candidature récente'),
                _buildMockList('Aucun avis'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMockList(String emptyMessage) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF14142B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(emptyMessage, style: const TextStyle(color: Colors.grey)),
      ),
    );
  }
}

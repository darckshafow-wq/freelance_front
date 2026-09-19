import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:freelance_front/core/constants/app_colors.dart';
import 'package:freelance_front/core/controllers/common/auth_controller.dart';
import 'package:freelance_front/core/models/common/proposal_model.dart';
import 'package:freelance_front/core/models/common/profile_model.dart';
import 'package:freelance_front/core/models/common/review_model.dart';
import 'package:freelance_front/core/models/common/user_model.dart';
import 'package:freelance_front/core/routes/route_names.dart';
import 'package:freelance_front/core/services/client/project_service.dart';
import 'package:freelance_front/core/services/common/profile_service.dart';
import 'package:freelance_front/app/smartphone/freelance/popup/freelance_dialogs.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class FreelanceProfileView extends StatefulWidget {
  const FreelanceProfileView({super.key});

  @override
  State<FreelanceProfileView> createState() => _FreelanceProfileViewState();
}

class _FreelanceProfileViewState extends State<FreelanceProfileView> {
  late Future<_ProfileData> _dataFuture;
  final String _bio = 'Freelance passionné par le développement et le design, prêt à relever de nouveaux défis.';

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadData();
  }

  Future<_ProfileData> _loadData() async {
    final service = ProjectService();
    final profileService = ProfileService();
    final user = await profileService.getCurrentUser();
    final proposals = await service.getFreelanceProposals();
    final reviews = await service.getClientReviews(); // assuming reviews service is common
    ProfileModel profile;
    try {
      profile = await profileService.getProfile();
    } catch (_) {
      profile = ProfileModel(id: 0, userId: user.id);
    }
    return _ProfileData(proposals, reviews, user, profile);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: FutureBuilder<_ProfileData>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.deepBlack));
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Impossible de charger le profil.'));
          }
          return _buildProfile(snapshot.data!);
        },
      ),
    );
  }

  Widget _buildProfile(_ProfileData data) {
    final accepted = data.proposals.where((p) => p.status.toUpperCase() == 'ACCEPTED').length;
    final average = data.reviews.isEmpty ? 0.0 : data.reviews.map((r) => r.rating).reduce((a, b) => a + b) / data.reviews.length;
    
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeader(context, data.user, data.profile),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Statistiques', style: TextStyle(color: AppColors.deepBlack, fontSize: 19, fontWeight: FontWeight.w800)),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(child: _statCard('$accepted', 'Projets gagnés', Icons.emoji_events_outlined, Colors.blue)),
                    const SizedBox(width: 10),
                    Expanded(child: _statCard('${data.reviews.length}', 'Avis reçus', Icons.rate_review_outlined, Colors.orange)),
                    const SizedBox(width: 10),
                    Expanded(child: _statCard(average.toStringAsFixed(1), 'Note moyenne', Icons.star_rounded, Colors.amber)),
                  ],
                ).animate().fadeIn(delay: 180.ms),
                const SizedBox(height: 30),
                const Text('Biographie', style: TextStyle(color: AppColors.deepBlack, fontSize: 19, fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                _whiteSection(Text(data.profile.bio ?? _bio, style: const TextStyle(color: AppColors.neutralGray, height: 1.5))),
                const SizedBox(height: 22),
                InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => context.pushNamed(RouteNames.freelanceProposals),
                  child: _whiteSection(Row(
                    children: [
                      const Icon(Icons.description_outlined, color: AppColors.primaryGold, size: 26),
                      const SizedBox(width: 14),
                      const Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Mes candidatures', style: TextStyle(color: AppColors.deepBlack, fontWeight: FontWeight.w800, fontSize: 16)),
                          SizedBox(height: 4),
                          Text('Suivre vos propositions envoyées', style: TextStyle(color: AppColors.neutralGray, fontSize: 12)),
                        ],
                      )),
                      Text('${data.proposals.length}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                      const Icon(Icons.chevron_right, color: AppColors.neutralGray),
                    ],
                  )),
                ),
                const SizedBox(height: 12),
                InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => context.pushNamed('freelanceSupport'),
                  child: _whiteSection(const Row(children: [
                    Icon(Icons.support_agent_outlined, color: AppColors.primaryGold, size: 26),
                    SizedBox(width: 14),
                    Expanded(child: Text('Aide et support', style: TextStyle(color: AppColors.deepBlack, fontWeight: FontWeight.w800, fontSize: 16))),
                    Icon(Icons.chevron_right, color: AppColors.neutralGray),
                  ])),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await context.read<AuthController>().logout();
                      if (context.mounted) {
                        context.go(RouteNames.login);
                      }
                    },
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Se déconnecter', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.errorRed,
                      side: const BorderSide(color: AppColors.errorRed, width: 2),
                      minimumSize: const Size.fromHeight(56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, UserModel user, ProfileModel profile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 70, 24, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(34)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 18, offset: Offset(0, 8))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primaryGold),
            child: const CircleAvatar(radius: 54, backgroundColor: AppColors.softWhite, backgroundImage: NetworkImage('https://i.pravatar.cc/300?u=free1'), child: Icon(Icons.person, size: 42, color: AppColors.neutralGray)),
          ).animate().scale(),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(user.fullName.isEmpty ? 'Freelance' : user.fullName, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900, color: AppColors.deepBlack)),
            IconButton(
              tooltip: 'Modifier le profil',
              icon: const Icon(Icons.edit_outlined, color: AppColors.primaryGold),
              onPressed: () async {
                final values = await showEditProfileDialog(context, name: user.fullName, bio: profile.bio ?? _bio);
                if (values != null) {
                  await ProfileService().updateProfile(fullName: values['name'], bio: values['bio']);
                  if (mounted) setState(() => _dataFuture = _loadData());
                }
              },
            ),
          ]),
          const SizedBox(height: 4),
          Text(user.email, style: const TextStyle(color: AppColors.neutralGray, fontSize: 13)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
            decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.verified, color: Colors.blue, size: 16), SizedBox(width: 6), Text('Profil Expert', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w700, fontSize: 12))]),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      height: 116,
      decoration: BoxDecoration(color: AppColors.deepBlack, borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: color, size: 20), const Spacer(), Text(value, style: const TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w900)), Text(label, maxLines: 2, style: const TextStyle(color: Colors.white60, fontSize: 10))]),
    );
  }

  Widget _whiteSection(Widget child) {
    return Container(width: double.infinity, padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)), child: child);
  }
}

class _ProfileData {
  final List<ProposalModel> proposals;
  final List<ReviewModel> reviews;
  final UserModel user;
  final ProfileModel profile;

  const _ProfileData(this.proposals, this.reviews, this.user, this.profile);
}

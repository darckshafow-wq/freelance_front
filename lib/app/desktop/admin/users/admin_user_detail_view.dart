import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:freelance_front/core/constants/app_colors.dart';
import 'package:freelance_front/core/constants/api_endpoints.dart';
import 'package:freelance_front/core/services/common/api_client.dart';
import 'package:go_router/go_router.dart';

class AdminUserDetailView extends StatefulWidget {
  final String id;
  const AdminUserDetailView({super.key, required this.id});

  @override
  State<AdminUserDetailView> createState() => _AdminUserDetailViewState();
}

class _AdminUserDetailViewState extends State<AdminUserDetailView> {
  final Dio _dio = ApiClient.instance;
  Map<String, dynamic>? _user;
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_user == null && _isLoading) {
      final extra = GoRouterState.of(context).extra;
      if (extra != null && extra is Map<String, dynamic>) {
        setState(() {
          _user = extra;
          _isLoading = false;
        });
      } else {
        _fetchUser();
      }
    }
  }

  @override
  void initState() {
    super.initState();
  }

  Future<void> _fetchUser() async {
    try {
      final resp = await _dio.get(ApiEndpoints.adminUsers, queryParameters: {'limit': 200});
      final list = resp.data as List;
      final found = list.firstWhere((u) => u['id'].toString() == widget.id, orElse: () => null);
      setState(() {
        _user = found != null ? Map<String, dynamic>.from(found) : null;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleSuspension(bool suspend) async {
    try {
      final id = _user!['id'];
      if (suspend) {
        await _dio.post(ApiEndpoints.adminUserSuspend(id));
      } else {
        await _dio.post(ApiEndpoints.adminUserActivate(id));
      }
      _fetchUser();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGold))
            : _user == null
                ? const Center(child: Text('Utilisateur introuvable', style: TextStyle(color: Colors.white54)))
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Back button
                        TextButton.icon(
                          onPressed: () => context.pop(),
                          icon: const Icon(Icons.arrow_back, color: AppColors.primaryGold),
                          label: const Text('Retour', style: TextStyle(color: AppColors.primaryGold)),
                        ),
                        const SizedBox(height: 16),
                        // User card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(color: AppColors.deepBlack, borderRadius: BorderRadius.circular(16)),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Avatar
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: AppColors.primaryGold.withValues(alpha: 0.2),
                                backgroundImage: _user!['profile']?['avatar_url'] != null
                                    ? NetworkImage(_user!['profile']['avatar_url'])
                                    : null,
                                child: _user!['profile']?['avatar_url'] == null
                                    ? Text(
                                        (_user!['full_name'] ?? 'U').substring(0, 1).toUpperCase(),
                                        style: const TextStyle(color: AppColors.primaryGold, fontSize: 36, fontWeight: FontWeight.bold),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 32),
                              // Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(_user!['full_name'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 8),
                                    Text(_user!['email'] ?? '', style: const TextStyle(color: Colors.white54, fontSize: 16)),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        _buildChip(_user!['role'] ?? '', Colors.blue),
                                        const SizedBox(width: 12),
                                        _buildChip(
                                          _user!['is_suspended'] == true ? 'Suspendu' : 'Actif',
                                          _user!['is_suspended'] == true ? AppColors.errorRed : AppColors.successGreen,
                                        ),
                                        if (_user!['profile']?['identity_verified'] == true) ...[
                                          const SizedBox(width: 12),
                                          _buildChip('Vérifié', AppColors.primaryGold),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Text('Créé le: ${(_user!['created_at'] ?? '').toString().substring(0, 10)}', style: const TextStyle(color: Colors.white38)),
                                    if (_user!['profile']?['bio'] != null) ...[
                                      const SizedBox(height: 16),
                                      const Text('Bio', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 4),
                                      Text(_user!['profile']['bio'], style: const TextStyle(color: Colors.white70)),
                                    ],
                                    if (_user!['profile']?['skills'] != null) ...[
                                      const SizedBox(height: 12),
                                      const Text('Compétences', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 4),
                                      Text(_user!['profile']['skills'], style: const TextStyle(color: Colors.white70)),
                                    ],
                                    if (_user!['profile']?['rating_average'] != null) ...[
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          const Icon(Icons.star, color: AppColors.primaryGold, size: 20),
                                          const SizedBox(width: 4),
                                          Text('${_user!['profile']['rating_average']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              // Actions
                              Column(
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () => _toggleSuspension(_user!['is_suspended'] != true),
                                    icon: Icon(_user!['is_suspended'] == true ? Icons.play_arrow : Icons.block),
                                    label: Text(_user!['is_suspended'] == true ? 'Activer' : 'Suspendre'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _user!['is_suspended'] == true ? AppColors.successGreen : AppColors.errorRed,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  if (_user!['role'] == 'FREELANCE')
                                    ElevatedButton.icon(
                                      onPressed: () async {
                                        await _dio.put(ApiEndpoints.adminUserVerifyIdentity(_user!['id']));
                                        _fetchUser();
                                      },
                                      icon: const Icon(Icons.verified_user),
                                      label: const Text('Vérifier Identité'),
                                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGold, foregroundColor: AppColors.deepBlack),
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
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}

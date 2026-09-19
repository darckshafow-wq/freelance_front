import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:freelance_front/core/constants/app_colors.dart';
import 'package:freelance_front/core/constants/api_endpoints.dart';
import 'package:freelance_front/core/services/common/api_client.dart';
import 'package:go_router/go_router.dart';

class AdminProjectDetailView extends StatefulWidget {
  final String id;
  const AdminProjectDetailView({super.key, required this.id});

  @override
  State<AdminProjectDetailView> createState() => _AdminProjectDetailViewState();
}

class _AdminProjectDetailViewState extends State<AdminProjectDetailView> {
  final Dio _dio = ApiClient.instance;
  Map<String, dynamic>? _project;
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_project == null && _isLoading) {
      final extra = GoRouterState.of(context).extra;
      if (extra != null && extra is Map<String, dynamic>) {
        setState(() {
          _project = extra;
          _isLoading = false;
        });
      } else {
        _fetchProject();
      }
    }
  }

  @override
  void initState() {
    super.initState();
  }

  Future<void> _fetchProject() async {
    try {
      final resp = await _dio.get(ApiEndpoints.adminProjects, queryParameters: {'limit': 200});
      final list = resp.data as List;
      final found = list.firstWhere((p) => p['id'].toString() == widget.id, orElse: () => null);
      setState(() {
        _project = found != null ? Map<String, dynamic>.from(found) : null;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'OPEN': return Colors.blue;
      case 'ASSIGNED': return Colors.orange;
      case 'IN_PROGRESS': return AppColors.primaryGold;
      case 'COMPLETED': return AppColors.successGreen;
      case 'CANCELLED': return AppColors.errorRed;
      default: return Colors.white54;
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
            : _project == null
                ? const Center(child: Text('Projet introuvable', style: TextStyle(color: Colors.white54)))
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextButton.icon(
                          onPressed: () => context.pop(),
                          icon: const Icon(Icons.arrow_back, color: AppColors.primaryGold),
                          label: const Text('Retour', style: TextStyle(color: AppColors.primaryGold)),
                        ),
                        const SizedBox(height: 16),
                        // Project info
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(color: AppColors.deepBlack, borderRadius: BorderRadius.circular(16)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(_project!['title'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: _statusColor(_project!['status'] ?? '').withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      _project!['status'] ?? '',
                                      style: TextStyle(color: _statusColor(_project!['status'] ?? ''), fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(_project!['description'] ?? '', style: const TextStyle(color: Colors.white70, height: 1.5)),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  const Icon(Icons.location_on, color: AppColors.primaryGold, size: 18),
                                  const SizedBox(width: 8),
                                  Text(_project!['localisation'] ?? 'Non spécifié', style: const TextStyle(color: Colors.white54)),
                                  const SizedBox(width: 32),
                                  const Icon(Icons.calendar_today, color: AppColors.primaryGold, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Prévu: ${(_project!['scheduled_at'] ?? '').toString().length >= 10 ? _project!['scheduled_at'].toString().substring(0, 10) : 'N/A'}',
                                    style: const TextStyle(color: Colors.white54),
                                  ),
                                  const SizedBox(width: 32),
                                  const Icon(Icons.person, color: AppColors.primaryGold, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Client: ${_project!['client']?['full_name'] ?? 'N/A'}',
                                    style: const TextStyle(color: Colors.white54),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Proposals
                        const Text('Propositions', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        ...(_project!['proposals'] as List? ?? []).map((prop) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(color: AppColors.deepBlack, borderRadius: BorderRadius.circular(12)),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: AppColors.primaryGold.withValues(alpha: 0.2),
                                  child: Text(
                                    (prop['freelance']?['full_name'] ?? 'F').substring(0, 1).toUpperCase(),
                                    style: const TextStyle(color: AppColors.primaryGold, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(prop['freelance']?['full_name'] ?? 'Freelance #${prop['freelance_id']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 4),
                                      Text(prop['message'] ?? '', style: const TextStyle(color: Colors.white54), maxLines: 2, overflow: TextOverflow.ellipsis),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Text('${prop['proposed_price']} FCFA', style: const TextStyle(color: AppColors.primaryGold, fontWeight: FontWeight.bold, fontSize: 16)),
                                const SizedBox(width: 16),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _statusColor(prop['status'] ?? '').withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(prop['status'] ?? '', style: TextStyle(color: _statusColor(prop['status'] ?? ''), fontSize: 12, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          );
                        }),
                        if ((_project!['proposals'] as List? ?? []).isEmpty)
                          const Text('Aucune proposition', style: TextStyle(color: Colors.white38)),
                        const SizedBox(height: 24),
                        // Delete
                        ElevatedButton.icon(
                          onPressed: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                backgroundColor: AppColors.deepBlack,
                                title: const Text('Supprimer ce projet ?', style: TextStyle(color: Colors.white)),
                                content: const Text('Cette action est irréversible.', style: TextStyle(color: Colors.white54)),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.errorRed),
                                    child: const Text('Supprimer', style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              ),
                            );
                            if (confirmed == true && mounted) {
                              await _dio.delete(ApiEndpoints.adminProjectDelete(_project!['id']));
                              if (mounted) context.pop();
                            }
                          },
                          icon: const Icon(Icons.delete),
                          label: const Text('Supprimer le projet'),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.errorRed, foregroundColor: Colors.white),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:freelance_front/core/constants/app_colors.dart';
import 'package:freelance_front/core/services/common/api_client.dart';
import 'package:freelance_front/core/constants/api_endpoints.dart';
import 'package:freelance_front/core/controllers/admin/admin_controller.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AdminDistrictsView extends StatefulWidget {
  final String cityId;
  const AdminDistrictsView({super.key, required this.cityId});

  @override
  State<AdminDistrictsView> createState() => _AdminDistrictsViewState();
}

class _AdminDistrictsViewState extends State<AdminDistrictsView> {
  List<dynamic> districts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDistricts();
  }

  Future<void> _fetchDistricts() async {
    setState(() => isLoading = true);
    try {
      final cityId = int.parse(widget.cityId);
      final res = await ApiClient.instance.get(ApiEndpoints.locationsDistricts(cityId));
      setState(() {
        districts = res.data is List ? res.data : [];
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void _showAddDistrictDialog() {
    final nameCtrl = TextEditingController();
    final latCtrl = TextEditingController();
    final lngCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Ajouter un Quartier', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogField(nameCtrl, 'Nom du quartier'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildDialogField(latCtrl, 'Latitude', keyboardType: TextInputType.number)),
                const SizedBox(width: 12),
                Expanded(child: _buildDialogField(lngCtrl, 'Longitude', keyboardType: TextInputType.number)),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ANNULER', style: TextStyle(color: Colors.white24))),
          ElevatedButton(
            onPressed: () async {
              final name = nameCtrl.text.trim();
              final lat = double.tryParse(latCtrl.text) ?? 0.0;
              final lng = double.tryParse(lngCtrl.text) ?? 0.0;
              if (name.isEmpty) return;

              Navigator.pop(ctx);
              final success = await context.read<AdminController>().createDistrict(int.parse(widget.cityId), name, lat, lng);
              if (success && mounted) {
                _fetchDistricts(); 
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Quartier ajouté !'), backgroundColor: Colors.green));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGold, foregroundColor: Colors.black),
            child: const Text('AJOUTER'),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogField(TextEditingController ctrl, String hint, {TextInputType? keyboardType}) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
        filled: true,
        fillColor: Colors.black.withValues(alpha: 0.2),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF111111),
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white54, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gestion des Quartiers',
                    style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900),
                  ).animate().fadeIn().slideX(begin: -0.1),
                  Text(
                    'Liste des zones pour la ville #${widget.cityId}',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 14),
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _showAddDistrictDialog,
                icon: const Icon(Icons.add_location_rounded),
                label: const Text('NOUVEAU QUARTIER'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGold,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 48),
          
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGold))
                : districts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.map_outlined, size: 64, color: Colors.white.withValues(alpha: 0.1)),
                            const SizedBox(height: 16),
                            const Text('Aucun quartier répertorié', style: TextStyle(color: Colors.white24, fontSize: 16)),
                          ],
                        ),
                      )
                    : GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                          childAspectRatio: 2.2,
                        ),
                        itemCount: districts.length,
                        itemBuilder: (context, index) {
                          final dynamic item = districts[index];
                          if (item is Map) {
                            final d = Map<String, dynamic>.from(item);
                            return _buildDistrictCard(d, index);
                          }
                          return const SizedBox();
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistrictCard(Map<String, dynamic> district, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.primaryGold.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: const Icon(Icons.location_on_rounded, color: AppColors.primaryGold, size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  district['name']?.toString() ?? 'Quartier',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'ID: ${district['id']}',
                  style: const TextStyle(color: Colors.white24, fontSize: 10),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.errorRed, size: 18),
            onPressed: () => _confirmDeleteDistrict(int.tryParse(district['id'].toString()) ?? 0, district['name']?.toString() ?? 'ce quartier'),
          ),
        ],
      ),
    ).animate().fadeIn(delay: (index * 40).ms).slideY(begin: 0.1);
  }

  void _confirmDeleteDistrict(int districtId, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Supprimer le quartier', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text('Voulez-vous vraiment supprimer le quartier $name ?', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ANNULER', style: TextStyle(color: Colors.white24))),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await context.read<AdminController>().deleteDistrict(districtId);
              if (success && mounted) {
                _fetchDistricts();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Quartier supprimé.'), backgroundColor: AppColors.errorRed));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.errorRed),
            child: const Text('SUPPRIMER'),
          ),
        ],
      ),
    );
  }
}

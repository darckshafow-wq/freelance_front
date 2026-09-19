import 'package:flutter/material.dart';
import 'package:freelance_front/core/constants/app_colors.dart';
import 'package:freelance_front/core/controllers/admin/admin_controller.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

class AdminLocationsView extends StatefulWidget {
  const AdminLocationsView({super.key});

  @override
  State<AdminLocationsView> createState() => _AdminLocationsViewState();
}

class _AdminLocationsViewState extends State<AdminLocationsView> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminController>().fetchCountries();
    });
  }

  void _showAddCountryDialog({Map<String, dynamic>? country}) {
    final bool isEditing = country != null;
    final nameCtrl = TextEditingController(text: country?['name']);
    final codeCtrl = TextEditingController(text: country?['code']);
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(isEditing ? 'Modifier le pays' : 'Ajouter un pays', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogField(nameCtrl, 'Nom du pays (ex: France)'),
            const SizedBox(height: 16),
            _buildDialogField(codeCtrl, 'Code (ex: FR)'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ANNULER', style: TextStyle(color: Colors.white24))),
          ElevatedButton(
            onPressed: () async {
              final name = nameCtrl.text.trim();
              final code = codeCtrl.text.trim();
              if (name.isEmpty || code.isEmpty) return;
              
              Navigator.pop(ctx);
              bool success;
              if (isEditing) {
                success = await context.read<AdminController>().updateCountry(country['id'], name, code);
              } else {
                success = await context.read<AdminController>().createCountry(name, code);
              }

              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEditing ? 'Pays mis à jour !' : 'Pays ajouté !'), backgroundColor: Colors.green));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGold, foregroundColor: Colors.black),
            child: Text(isEditing ? 'ENREGISTRER' : 'AJOUTER'),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogField(TextEditingController ctrl, String hint) {
    return TextField(
      controller: ctrl,
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

  void _confirmDeleteCountry(int countryId, String countryName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Supprimer le pays', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text('Voulez-vous vraiment supprimer le pays $countryName ? Toutes ses villes et quartiers seront supprimés.', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ANNULER', style: TextStyle(color: Colors.white24))),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await context.read<AdminController>().deleteCountry(countryId);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pays supprimé.'), backgroundColor: AppColors.errorRed));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.errorRed),
            child: const Text('SUPPRIMER'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AdminController>();

    return Container(
      color: const Color(0xFF111111),
      padding: const EdgeInsets.all(40),
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
                    'Gestion des Localisations',
                    style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900),
                  ).animate().fadeIn().slideX(begin: -0.1),
                  const SizedBox(height: 8),
                  const Text(
                    'Configurez les pays, villes et zones géographiques de la plateforme.',
                    style: TextStyle(color: Colors.white54, fontSize: 14),
                  ).animate().fadeIn(delay: 200.ms),
                ],
              ),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _showAddCountryDialog,
                    icon: const Icon(Icons.add_location_alt_rounded),
                    label: const Text('NOUVEAU PAYS'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGold,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    onPressed: () => controller.fetchCountries(),
                    icon: const Icon(Icons.refresh_rounded, color: Colors.white54),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 48),
          
          Container(
            constraints: const BoxConstraints(maxWidth: 600),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Rechercher un pays...',
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                filled: true,
                fillColor: const Color(0xFF1C1C1E),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
          
          const SizedBox(height: 32),
          
          Expanded(
            child: controller.isLoading && controller.countries.isEmpty
                ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGold))
                : _buildCountriesGrid(controller),
          ),
        ],
      ),
    );
  }

  Widget _buildCountriesGrid(AdminController controller) {
    final List<dynamic> rawCountries = controller.countries;
    
    final filteredCountries = rawCountries.where((c) {
      if (c is! Map) return false;
      final String name = (c['name'] ?? '').toString().toLowerCase();
      return name.contains(_searchQuery.toLowerCase());
    }).toList();

    if (filteredCountries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map_outlined, size: 64, color: Colors.white.withValues(alpha: 0.1)),
            const SizedBox(height: 16),
            const Text('Aucun pays trouvé', style: TextStyle(color: Colors.white24, fontSize: 16)),
          ],
        ),
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
        childAspectRatio: 1.2,
      ),
      itemCount: filteredCountries.length,
      itemBuilder: (context, index) {
        final dynamic item = filteredCountries[index];
        if (item is Map) {
          final country = Map<String, dynamic>.from(item);
          return _buildCountryCard(country, index);
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildCountryCard(Map<String, dynamic> country, int index) {
    final List cities = (country['cities'] as List? ?? []);
    final String countryId = (country['id'] ?? '0').toString();
    
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white.withValues(alpha: 0.02),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGold.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.public_rounded, color: AppColors.primaryGold, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        country['name']?.toString() ?? 'Pays inconnu',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Code: ${country['code'] ?? 'N/A'}',
                        style: const TextStyle(color: Colors.white38, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _showAddCountryDialog(country: country),
                  icon: const Icon(Icons.edit_outlined, color: Colors.blueAccent, size: 20),
                ),
                IconButton(
                  onPressed: () => _confirmDeleteCountry(int.tryParse(countryId) ?? 0, country['name'] ?? 'ce pays'),
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.errorRed, size: 20),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${cities.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900),
                  ),
                  const Text('VILLES', style: TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                ],
              ),
            ),
          ),
          
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => context.pushNamed('adminCountryDetail', pathParameters: {'countryId': countryId}),
              style: TextButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.05),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              ),
              child: const Text('GÉRER LES VILLES', style: TextStyle(color: AppColors.primaryGold, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: (index * 50).ms).slideY(begin: 0.1);
  }
}

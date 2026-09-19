import 'package:flutter/material.dart';
import 'package:freelance_front/core/constants/app_colors.dart';
import 'package:freelance_front/core/controllers/admin/admin_controller.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

class AdminCountryDetailView extends StatefulWidget {
  final String countryId;
  const AdminCountryDetailView({super.key, required this.countryId});

  @override
  State<AdminCountryDetailView> createState() => _AdminCountryDetailViewState();
}

class _AdminCountryDetailViewState extends State<AdminCountryDetailView> {
  String _searchQuery = '';
  Map<String, dynamic>? _country;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCountry();
  }

  Future<void> _loadCountry() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final countryIdInt = int.tryParse(widget.countryId) ?? 0;
      if (countryIdInt == 0) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }
      
      final adminCtrl = context.read<AdminController>();
      final data = await adminCtrl.adminService.getCountryFull(countryIdInt);
      
      if (mounted) {
        setState(() {
          _country = Map<String, dynamic>.from(data);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading country: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showAddCityDialog({Map<String, dynamic>? city}) {
    final bool isEditing = city != null;
    final nameCtrl = TextEditingController(text: city?['name']);
    final latCtrl = TextEditingController(text: city?['latitude']?.toString());
    final lngCtrl = TextEditingController(text: city?['longitude']?.toString());
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(isEditing ? 'Modifier la ville' : 'Ajouter une ville', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogField(nameCtrl, 'Nom de la ville'),
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
              bool success;
              if (isEditing) {
                success = await context.read<AdminController>().updateCity(city['id'], name, lat, lng);
              } else {
                success = await context.read<AdminController>().createCity(int.parse(widget.countryId), name, lat, lng);
              }

              if (success && mounted) {
                _loadCountry(); // Refresh
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEditing ? 'Ville mise à jour !' : 'Ville ajoutée !'), backgroundColor: Colors.green));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGold, foregroundColor: Colors.black),
            child: Text(isEditing ? 'ENREGISTRER' : 'AJOUTER'),
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

  void _confirmDeleteCountry(int id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Supprimer le pays', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text('Voulez-vous vraiment supprimer le pays $name ? Toutes ses villes et quartiers seront supprimés.', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ANNULER', style: TextStyle(color: Colors.white24))),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await context.read<AdminController>().deleteCountry(id);
              if (success && mounted) {
                context.pop();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pays supprimé'), backgroundColor: AppColors.errorRed));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.errorRed),
            child: const Text('SUPPRIMER'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteCity(int id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Supprimer la ville', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text('Voulez-vous vraiment supprimer la ville $name ?', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ANNULER', style: TextStyle(color: Colors.white24))),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await context.read<AdminController>().deleteCity(id);
              if (success && mounted) {
                _loadCountry(); // Refresh
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ville supprimée'), backgroundColor: AppColors.errorRed));
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
    context.watch<AdminController>();
    final country = _country;

    if (country == null && !_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_off_rounded, color: Colors.white24, size: 64),
            const SizedBox(height: 16),
            const Text('Pays introuvable ou erreur de chargement.', style: TextStyle(color: Colors.white54)),
            const SizedBox(height: 24),
            TextButton(onPressed: () => context.pop(), child: const Text('RETOUR', style: TextStyle(color: AppColors.primaryGold))),
          ],
        ),
      );
    }

    final List citiesList = country != null && country['cities'] is List ? country['cities'] as List : [];
    
    final filteredCities = citiesList.where((city) {
       if (city is! Map) return false;
       final String name = (city['name'] ?? '').toString().toLowerCase();
       return name.contains(_searchQuery.toLowerCase());
    }).toList();

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
                onPressed: () => context.pop(),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    country != null ? (country['name'] ?? 'Détail Pays') : 'Chargement...',
                    style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900),
                  ).animate().fadeIn().slideX(begin: -0.1),
                  Text(
                    'Gestion des villes pour ce pays',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 14),
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _showAddCityDialog,
                icon: const Icon(Icons.add_location_rounded),
                label: const Text('AJOUTER UNE VILLE'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGold,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(width: 16),
              if (country != null)
                OutlinedButton.icon(
                  onPressed: () => _confirmDeleteCountry(int.tryParse(country['id'].toString()) ?? 0, country['name']?.toString() ?? ''),
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: const Text('SUPPRIMER PAYS'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.errorRed,
                    side: const BorderSide(color: AppColors.errorRed),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
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
                hintText: 'Rechercher une ville...',
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.2)),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                filled: true,
                fillColor: const Color(0xFF1C1C1E),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
          ),

          const SizedBox(height: 32),

          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGold))
              : _buildCitiesGrid(filteredCities),
          ),
        ],
      ),
    );
  }

  Widget _buildCitiesGrid(List filteredCities) {
    if (filteredCities.isEmpty) {
      return const Center(child: Text('Aucune ville trouvée', style: TextStyle(color: Colors.white24)));
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 1.3,
      ),
      itemCount: filteredCities.length,
      itemBuilder: (context, index) {
        final dynamic item = filteredCities[index];
        if (item is Map) {
          return _buildCityCard(Map<String, dynamic>.from(item), index);
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildCityCard(Map<String, dynamic> city, int index) {
    final String cityId = (city['id'] ?? '0').toString();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.location_city_rounded, color: AppColors.primaryGold, size: 24),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: Colors.blueAccent, size: 20),
                    onPressed: () => _showAddCityDialog(city: city),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: AppColors.errorRed, size: 20),
                    onPressed: () => _confirmDeleteCity(int.tryParse(cityId) ?? 0, city['name'] ?? 'Ville'),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          Text(
            city['name']?.toString() ?? 'Ville',
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            'Lat: ${city['latitude'] ?? 0} | Lng: ${city['longitude'] ?? 0}',
            style: const TextStyle(color: Colors.white24, fontSize: 10),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => context.pushNamed('adminCityDetail', pathParameters: {'cityId': cityId}),
              style: TextButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.05),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('VOIR LES QUARTIERS', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: (index * 40).ms).slideY(begin: 0.1);
  }
}

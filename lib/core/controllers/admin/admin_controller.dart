import 'package:flutter/material.dart';
import 'package:freelance_front/core/services/admin/admin_service.dart';
import 'package:freelance_front/core/models/common/user_model.dart';
import 'package:freelance_front/core/models/common/project_model.dart';
import 'package:freelance_front/core/models/admin/category_model.dart';

class AdminController extends ChangeNotifier {
  final AdminService _adminService = AdminService();
  AdminService get adminService => _adminService;

  bool isLoading = false;
  String? errorMessage;

  Map<String, dynamic>? overview;
  List<UserModel> users = [];
  List<ProjectModel> projects = [];
  List<dynamic> reports = [];
  Map<String, dynamic>? stats;
  List<dynamic> auditLogs = [];
  List<dynamic> systemWarnings = [];
  List<dynamic> pendingFeedbacks = [];
  List<CategoryModel> categories = [];

  List<dynamic> broadcasts = [];

  void _setLoading(bool value) {
    isLoading = value;
    if (value) errorMessage = null;
    notifyListeners();
  }

  Future<void> fetchOverview() async {
    _setLoading(true);
    try {
      overview = await _adminService.getOverview();
    } catch (e) {
      errorMessage = 'Erreur overview: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchUsers() async {
    _setLoading(true);
    try {
      users = await _adminService.getUsers();
    } catch (e) {
      errorMessage = 'Erreur utilisateurs: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchProjects() async {
    _setLoading(true);
    try {
      projects = await _adminService.getProjects();
    } catch (e) {
      errorMessage = 'Erreur projets: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchReports() async {
    _setLoading(true);
    try {
      reports = await _adminService.getReports();
    } catch (e) {
      errorMessage = 'Erreur signalements: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchStats() async {
    _setLoading(true);
    try {
      stats = await _adminService.getStats();
    } catch (e) {
      errorMessage = 'Erreur stats: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchAuditLogs() async {
    _setLoading(true);
    try {
      auditLogs = await _adminService.getAuditLogs();
    } catch (e) {
      errorMessage = 'Erreur audit logs: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchSystemWarnings() async {
    _setLoading(true);
    try {
      systemWarnings = await _adminService.getSystemWarnings();
    } catch (e) {
      errorMessage = 'Erreur warnings: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resolveWarning(int id) async {
    try {
      final success = await _adminService.resolveSystemWarning(id);
      if (success) await fetchSystemWarnings();
      return success;
    } catch (e) {
      return false;
    }
  }

  Future<void> fetchBroadcasts() async {
    _setLoading(true);
    try {
      broadcasts = [
        {'id': 1, 'title': 'Maintenance prévue', 'content': 'Le serveur sera en maintenance ce soir à 22h.', 'target': 'ALL', 'created_at': DateTime.now().subtract(const Duration(days: 1)).toIso8601String()},
        {'id': 2, 'title': 'Nouveaux tarifs', 'content': 'Découvrez les nouveaux tarifs pour les freelances.', 'target': 'FREELANCE', 'created_at': DateTime.now().subtract(const Duration(days: 3)).toIso8601String()},
      ];
    } catch (e) {
      errorMessage = 'Erreur broadcasts: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchCategories() async {
    _setLoading(true);
    try {
      categories = await _adminService.getCategories();
    } catch (e) {
      errorMessage = 'Erreur catégories: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createCategory(String name, String description) async {
    try {
      await _adminService.createCategory(name, description);
      await fetchCategories();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateCategory(int id, String name, String description) async {
    try {
      final success = await _adminService.updateCategory(id, name, description);
      if (success) await fetchCategories();
      return success;
    } catch (e) {
      return false;
    }
  }

  Future<bool> suspendUser(int id) async {
    try {
      final success = await _adminService.suspendUser(id);
      if (success) await fetchUsers();
      return success;
    } catch (e) {
      return false;
    }
  }

  Future<bool> activateUser(int id) async {
    try {
      final success = await _adminService.activateUser(id);
      if (success) await fetchUsers();
      return success;
    } catch (e) {
      return false;
    }
  }

  Future<bool> verifyUser(int id) async {
    try {
      final success = await _adminService.verifyIdentity(id);
      if (success) await fetchUsers();
      return success;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteProject(int id) async {
    try {
      final success = await _adminService.deleteProject(id);
      if (success) await fetchProjects();
      return success;
    } catch (e) {
      return false;
    }
  }

  Future<bool> resolveReport(int id) async {
    try {
      final success = await _adminService.resolveReport(id);
      if (success) await fetchReports();
      return success;
    } catch (e) {
      return false;
    }
  }

  Future<bool> sendBroadcast(String title, String message, {String? target}) async {
    _setLoading(true);
    try {
      return await _adminService.sendBroadcast(title, message, target: target);
    } catch (e) {
      errorMessage = 'Erreur broadcast: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // LOCATIONS
  // ==========================================
  List<dynamic> countries = [];
  
  Future<void> fetchCountries() async {
    _setLoading(true);
    try {
      final List<dynamic> rawCountries = await _adminService.getCountries();
      
      final List<Map<String, dynamic>> enrichedCountries = [];
      
      for (var country in rawCountries) {
        if (country is Map) {
          final dynamic cidRaw = country['id'];
          final int countryId = int.tryParse(cidRaw.toString()) ?? 0;
          if (countryId == 0) continue;
          
          final cities = await _adminService.getCities(countryId);
          
          final enriched = Map<String, dynamic>.from(country);
          enriched['cities'] = cities;
          enrichedCountries.add(enriched);
        }
      }
      
      countries = enrichedCountries;
    } catch (e) {
      errorMessage = 'Erreur pays: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createCountry(String name, String code) async {
    _setLoading(true);
    try {
      final success = await _adminService.createCountry(name, code);
      if (success) await fetchCountries();
      return success;
    } catch (e) {
      errorMessage = 'Erreur création pays: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateCountry(int id, String name, String code) async {
    _setLoading(true);
    try {
      final success = await _adminService.updateCountry(id, name, code);
      if (success) await fetchCountries();
      return success;
    } catch (e) {
      errorMessage = 'Erreur modification pays: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteCountry(int id) async {
    _setLoading(true);
    try {
      final success = await _adminService.deleteCountry(id);
      if (success) await fetchCountries();
      return success;
    } catch (e) {
      errorMessage = 'Erreur suppression pays: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createCity(int countryId, String name, double lat, double lng) async {
    _setLoading(true);
    try {
      final success = await _adminService.createCity(countryId, name, lat, lng);
      if (success) await fetchCountries();
      return success;
    } catch (e) {
      errorMessage = 'Erreur création ville: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateCity(int id, String name, double lat, double lng) async {
    _setLoading(true);
    try {
      final success = await _adminService.updateCity(id, name, lat, lng);
      if (success) await fetchCountries();
      return success;
    } catch (e) {
      errorMessage = 'Erreur modification ville: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteCity(int cityId) async {
    _setLoading(true);
    try {
      final success = await _adminService.deleteCity(cityId);
      if (success) await fetchCountries();
      return success;
    } catch (e) {
      errorMessage = 'Erreur suppression ville: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createDistrict(int cityId, String name, double lat, double lng) async {
    _setLoading(true);
    try {
      final success = await _adminService.createDistrict(cityId, name, lat, lng);
      if (success) await fetchCountries();
      return success;
    } catch (e) {
      errorMessage = 'Erreur création quartier: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteDistrict(int districtId) async {
    _setLoading(true);
    try {
      final success = await _adminService.deleteDistrict(districtId);
      if (success) await fetchCountries();
      return success;
    } catch (e) {
      errorMessage = 'Erreur suppression quartier: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }
}

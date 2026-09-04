import 'package:flutter/material.dart';
import 'package:freelance_front/core/models/common/user_model.dart';
import 'package:freelance_front/core/models/common/profile_model.dart';
import 'package:freelance_front/core/services/client/client_freelance_service.dart';

class FreelanceController extends ChangeNotifier {
  final ClientFreelanceService _freelanceService = ClientFreelanceService();
  
  bool isLoading = false;
  List<UserModel> freelances = [];
  UserModel? selectedFreelance;
  ProfileModel? get selectedFreelanceProfile => selectedFreelance?.profile;

  Future<void> fetchFreelances() async {
    isLoading = true;
    notifyListeners();

    try {
      freelances = await _freelanceService.getFreelancers();
    } catch (e) {
      debugPrint("Erreur lors de la récupération de l'annuaire : $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchFreelanceDetail(int id) async {
    isLoading = true;
    notifyListeners();

    try {
      selectedFreelance = await _freelanceService.getFreelanceDetail(id);
    } catch (e) {
      debugPrint("Erreur lors de la récupération des détails du freelance : $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

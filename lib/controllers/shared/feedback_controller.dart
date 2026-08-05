import 'package:flutter/material.dart';
import '../../models/shared/feedback_model.dart';
import '../../models/auth/user_model.dart';
import '../../services/api/shared/feedback_api_service.dart';

class FeedbackController extends ChangeNotifier {
  final FeedbackApiService _apiService;

  FeedbackController({FeedbackApiService? apiService})
      : _apiService = apiService ?? FeedbackApiService();

  bool isLoading = false;
  String? error;
  String? get errorMessage => error; // Alias pour la compatibilité

  List<FeedbackModel> myFeedbacks = [];
  List<FeedbackModel> allFeedbacks = []; // Utilisé par l'admin
  List<FeedbackModel> get adminFeedbacks => allFeedbacks; // Alias

  FeedbackModel? selectedFeedback; // Pour le détail d'un feedback (Admin)

  /// Soumet un feedback (Client ou Freelance)
  Future<bool> submitFeedback({
    required UserRole role,
    required String content,
    required FeedbackCategory category,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final trimmedContent = content.trim();
      if (trimmedContent.isEmpty) {
        error = 'Veuillez saisir un message';
        isLoading = false;
        notifyListeners();
        return false;
      }

      final response = await _apiService.submitFeedback(
        role: role,
        content: trimmedContent,
        category: category,
      );

      if (response.isSuccess && response.data != null) {
        // Ajout en haut de la liste
        myFeedbacks.insert(0, response.data!);
        isLoading = false;
        notifyListeners();
        return true;
      } else {
        error = response.message ?? 'Erreur lors de l\'envoi du feedback';
      }
    } catch (e) {
      error = 'Échec de l’envoi du feedback: $e';
    }

    isLoading = false;
    notifyListeners();
    return false;
  }

  /// Récupère la liste de mes feedbacks (Client ou Freelance)
  Future<void> fetchMyFeedbacks(UserRole role) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await _apiService.getMyFeedbacks(role);
      if (response.isSuccess && response.data != null) {
        myFeedbacks = response.data!;
      } else {
        error = response.message ?? 'Erreur lors de la récupération';
      }
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  /// (Admin) Récupère la liste de tous les feedbacks
  Future<void> fetchAllFeedbacks({String? status}) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await _apiService.getAllFeedbacks(status: status);
      if (response.isSuccess && response.data != null) {
        allFeedbacks = response.data!;
      } else {
        error = response.message ?? 'Erreur lors de la récupération (admin)';
      }
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  /// Alias pour la compatibilité avec Admin Desktop
  Future<void> fetchAllAdminFeedbacks({FeedbackStatus? filterStatus}) async {
    return fetchAllFeedbacks(status: filterStatus?.name.toLowerCase());
  }

  /// (Admin) Récupérer le détail d'un feedback
  Future<void> fetchFeedbackDetail(int id) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await _apiService.getFeedbackDetail(id);
      if (response.isSuccess && response.data != null) {
        selectedFeedback = response.data;
        // Met également à jour la liste locale si présent
        final index = allFeedbacks.indexWhere((f) => f.id == id);
        if (index != -1) {
          allFeedbacks[index] = response.data!;
        }
      } else {
        error = response.message ?? 'Feedback introuvable.';
      }
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  /// (Admin) Répondre à un feedback
  Future<bool> replyToFeedback({
    required int feedbackId,
    required String adminReply,
    required FeedbackStatus status,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await _apiService.replyToFeedback(
        feedbackId: feedbackId,
        adminReply: adminReply,
        status: status,
      );

      if (response.isSuccess && response.data != null) {
        // Mise à jour locale du feedback
        final index = allFeedbacks.indexWhere((fb) => fb.id == feedbackId);
        if (index != -1) {
          allFeedbacks[index] = response.data!;
        }
        if (selectedFeedback?.id == feedbackId) {
          selectedFeedback = response.data!;
        }
        isLoading = false;
        notifyListeners();
        return true;
      } else {
        error = response.message ?? 'Erreur lors de la réponse';
      }
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();
    return false;
  }
}

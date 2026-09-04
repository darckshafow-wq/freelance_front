import 'package:flutter/material.dart';
import 'package:freelance_front/core/models/common/profile_model.dart';
import 'package:freelance_front/core/models/common/user_model.dart';
import 'package:freelance_front/core/services/common/profile_service.dart';

class ProfileController extends ChangeNotifier {
  final ProfileService _profileService = ProfileService();

  static int? resolveUserId(dynamic value, {int? currentUserId}) {
    if (value == 'me') {
      return currentUserId;
    }

    if (value == null) {
      return null;
    }

    final parsed = int.tryParse(value.toString());
    if (parsed == null || parsed <= 0) {
      return null;
    }

    return parsed;
  }

  bool isLoading = false;
  String? errorMessage;
  ProfileModel? profile;

  Future<void> loadProfile() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      profile = await _profileService.getProfile();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<UserModel?> updateProfile({String? fullName, String? bio}) async {
    isLoading = true;
    notifyListeners();
    try {
      final user = await _profileService.updateProfile(fullName: fullName, bio: bio);
      await loadProfile();
      return user;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }
}

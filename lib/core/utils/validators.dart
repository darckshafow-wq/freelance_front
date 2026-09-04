class Validators {
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'L’email est requis.';
    }
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!regex.hasMatch(value.trim())) {
      return 'Email invalide.';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le mot de passe est requis.';
    }
    if (value.length < 6) {
      return 'Le mot de passe doit contenir au moins 6 caractères.';
    }
    return null;
  }

  static String? required(String? value, [String label = 'Ce champ']) {
    if (value == null || value.trim().isEmpty) {
      return '$label est requis.';
    }
    return null;
  }
}

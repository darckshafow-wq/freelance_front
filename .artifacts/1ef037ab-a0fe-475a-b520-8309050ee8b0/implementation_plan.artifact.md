# Plan : Désactivation API et Simulation d'Authentification

Ce plan vise à rendre l'application totalement indépendante du backend tout en maintenant l'illusion d'une application fonctionnelle (système de mock intelligent).

## 🛠️ Désactivation Globale du Réseau (Mock Mode)

### [MODIFY] [api_core.dart](file:///home/shadow-12/Bureau/freelance_front/lib/services/api/api_core.dart)
- S'assurer que `mockMode` est à `true`.
- Intercepter tous les appels `get`, `post`, `put`, `delete` pour retourner des succès systématiques avec des données vides ou par défaut.

---

## 🔐 Simulation d'Authentification (Effet "Vivant")

### [MODIFY] [auth_controller.dart](file:///home/shadow-12/Bureau/freelance_front/lib/controllers/auth/auth_controller.dart)
- **Login** : Simuler une vérification de 1.5 seconde (Loading spinner visible), puis rediriger systématiquement avec un utilisateur Mock Client.
- **Register** : Simuler une création de compte, puis rediriger vers la page de vérification OTP (qui validera n'importe quel code).
- **OTP** : La méthode `verifyOtp` retournera toujours `true` après un court délai.

---

## 📦 Injection de Données de Design (Mock Controllers)

Pour éviter d'avoir des pages vides, les contrôleurs injecteront des données de test si `mockMode` est actif.

### [MODIFY] Controllers
- `TaskController` : Retourner une liste de 3 missions Client factices (Design, Dev, Marketing).
- `FreelanceTaskController` : Retourner une liste de missions recommandées.
- `NotificationController` : Retourner 2 notifications de bienvenue.
- `ChatListController` : Retourner une conversation active de test.

---

## 🧹 Nettoyage Final

### [DELETE] [client_home_page.dart](file:///home/shadow-12/Bureau/freelance_front/lib/views/smartphone/client/home/client_home_page.dart)
- Suppression définitive du fichier inutilisé.

## Verification Plan

### Tests Manuels
1. Effectuer un parcours complet : Landing -> Register -> OTP -> Home.
2. Vérifier que les indicateurs de chargement (Spinners) sont visibles brièvement pour donner l'impression de travail réel.
3. Confirmer que les pages (Home, Missions) ne sont pas vides mais affichent les données injectées pour le design.

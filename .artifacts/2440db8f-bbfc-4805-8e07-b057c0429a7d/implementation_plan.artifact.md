# Amélioration de la navigation et des pages Client/Freelance

Ce plan vise à corriger les bugs signalés, améliorer l'interface utilisateur des profils et des détails de mission, et assurer une cohérence entre les modes Client et Freelance en utilisant la `FloatingExpandableNav`.

## User Review Required

> [!IMPORTANT]
> La navigation flottante sera désormais utilisée pour les deux types d'utilisateurs. Le bouton central de la barre servira à créer un projet pour le Client et à accéder aux opportunités pour le Freelance.

## Proposed Changes

### Core & Services
#### [MODIFY] [route_names.dart](file:///home/shadow-66/freelance_front/lib/core/routes/route_names.dart)
- Ajouter `clientProjectProposals`.

#### [MODIFY] [project_service.dart](file:///home/shadow-66/freelance_front/lib/core/services/client/project_service.dart)
- Ajouter `getProject(int id)` pour récupérer un projet spécifique.
- Ajouter `submitProposal(int projectId, double budget, String message)` pour permettre aux freelances de postuler.

### Navigation
#### [MODIFY] [floating_expandable_nav.dart](file:///home/shadow-66/freelance_front/lib/core/widgets/floating_expandable_nav.dart)
- Supprimer toute référence à "Talents".
- Ajouter l'onglet "Profil".
- Ajuster les icônes et labels pour être génériques ou adaptables.

#### [MODIFY] [client_main_view.dart](file:///home/shadow-66/freelance_front/lib/app/smartphone/client/home/client_main_view.dart)
- Mettre à jour la gestion des index pour correspondre à la nouvelle `FloatingExpandableNav`.

#### [MODIFY] [freelance_main_view.dart](file:///home/shadow-66/freelance_front/lib/app/smartphone/freelance/home/freelance_main_view.dart)
- Remplacer la `BottomNavigationBar` actuelle par `FloatingExpandableNav`.

### Freelance Implementation
#### [MODIFY] [freelance_chat_list_view.dart](file:///home/shadow-66/freelance_front/lib/app/smartphone/freelance/chat/freelance_chat_list_view.dart)
- Fixer l'import de `ConversationModel`.

#### [MODIFY] [freelance_profile_view.dart](file:///home/shadow-66/freelance_front/lib/app/smartphone/freelance/profile/freelance_profile_view.dart)
- Fixer l'import d' `AuthController`.
- Améliorer le design pour correspondre au profil Client.

#### [MODIFY] [freelance_home_view.dart](file:///home/shadow-66/freelance_front/lib/app/smartphone/freelance/home/freelance_home_view.dart)
- Implémenter le flux de projets validés.

#### [MODIFY] [freelance_project_detail_view.dart](file:///home/shadow-66/freelance_front/lib/app/smartphone/freelance/projects/freelance_project_detail_view.dart)
- Améliorer le design et finaliser le bouton "Postuler" avec la popup.

### UI Improvements
#### [MODIFY] [client_profile_view.dart](file:///home/shadow-66/freelance_front/lib/app/smartphone/client/profile/client_profile_view.dart)
- Appliquer les améliorations de design demandées.

#### [MODIFY] [client_project_detail_view.dart](file:///home/shadow-66/freelance_front/lib/app/smartphone/client/projects/client_project_detail_view.dart)
- Améliorer l'affichage des détails.

## Verification Plan

### Automated Tests
- Vérifier la compilation et l'absence d'erreurs de type.
- Tester les routes avec `GoRouter`.

### Manual Verification
- Tester la navigation entre les onglets sur Client et Freelance.
- Vérifier que l'onglet "Talent" a disparu.
- Tester la soumission d'une candidature par un freelance.
- Vérifier le design des profils et détails.

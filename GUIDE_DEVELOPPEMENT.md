# 📖 Guide de Développement — Freelance Platform

> **Dernière mise à jour :** Juillet 2026  
> Ce document explique comment le projet est organisé et **comment travailler dessus sans se perdre**.

---

## 🗂️ Structure du projet

```
freelance_front/
└── lib/
    ├── main.dart                  ← Point d'entrée de l'app
    ├── constants/                 ← Couleurs, thèmes, typographies
    ├── models/                    ← Structures de données (ex: UserModel)
    ├── services/
    │   └── api/                   ← Communication avec le backend
    │       ├── api_core.dart      ← Client HTTP (GET, POST, PUT, DELETE)
    │       ├── api_endpoints.dart ← Toutes les URLs du backend
    │       ├── api_response.dart  ← Wrapper de réponse API
    │       ├── mock_data.dart     ← Données fictives pour les tests
    │       ├── freelance/         ← Services spécifiques au rôle freelance
    │       ├── client/            ← Services spécifiques au rôle client
    │       └── admin/             ← Services spécifiques au rôle admin
    ├── controllers/               ← Logique métier entre vue et service
    │   ├── auth_controller.dart   ← Connexion / déconnexion / session
    │   ├── notification_controller.dart
    │   ├── task_controller.dart
    │   ├── freelance/             ← Contrôleurs du freelance
    │   ├── client/                ← Contrôleurs du client
    │   └── admin/                 ← Contrôleurs de l'admin
    ├── routes/                    ← Navigation de l'application
    │   ├── app_router.dart        ← Routeur principal (routes publiques + délégation)
    │   ├── freelance_routes.dart  ← Routes du freelance
    │   ├── client_routes.dart     ← Routes du client
    │   └── admin_routes.dart      ← Routes de l'admin
    └── views/
        └── smartphone/            ← Toutes les pages de l'app
            ├── onbor/             ← Onboarding / landing
            ├── auth_smartphone/   ← Login, register, OTP, mot de passe
            ├── notification/      ← Pages de notifications
            ├── freelance/         ← Pages réservées au freelance
            │   ├── home/
            │   ├── dashboard/
            │   ├── applications/
            │   ├── profile/
            │   └── tasks/
            └── client/            ← Pages réservées au client
                ├── home/
                ├── missions/
                ├── applications/
                └── profile/
```

---

## 🧠 Comment le projet est architecturé (MVC simplifié)

L'app suit une architecture en **4 couches** :

```
[ Vue (View) ]
      ↕  affiche les données, capte les actions utilisateur
[ Contrôleur (Controller) ]
      ↕  orchestre la logique, appelle le service
[ Service / API ]
      ↕  fait les requêtes HTTP au backend
[ Modèle (Model) ]
     représente les données (UserModel, TaskModel…)
```

### Exemple concret : Page de profil du freelance

| Couche | Fichier | Rôle |
|--------|---------|------|
| **Vue** | `views/smartphone/freelance/profile/freelance_profile_page.dart` | Affiche le profil, appelle le contrôleur |
| **Contrôleur** | `controllers/freelance/profil_controller.dart` | Appelle le service, retourne un `UserModel?` |
| **Service** | `services/api/api_core.dart` | Fait le `GET /statistics/freelancer/{id}` |
| **Endpoint** | `services/api/api_endpoints.dart` | Contient `freelancerStats(userId)` |
| **Modèle** | `models/user_model.dart` | Classe `UserModel` avec `fromJson()` |

---

## 🚦 Système de routage

Le routage est divisé en **4 fichiers** :

### `app_router.dart` — Routes publiques
Gère les routes accessibles sans connexion :
- `/landing` → Page d'accueil
- `/login` → Connexion
- `/register`, `/create-account` → Inscription
- `/verification` → Code OTP
- `/forget-password` → Mot de passe oublié
- `/role-selection` → Choix du rôle
- `/notifications` → Liste des notifs (toutes les rôles)

### `freelance_routes.dart` — Routes du Freelance
Toutes les routes commençant par `/freelance/` :
- `/freelance/home` → Page d'accueil freelance
- `/freelance/dashboard` → Tableau de bord
- `/freelance/applications` → Mes candidatures
- `/freelance/profile` → Mon profil
- `/freelance/job-detail` → Détail d'une offre

### `client_routes.dart` — Routes du Client
Toutes les routes commençant par `/client/` :
- `/client/home` → Page d'accueil client
- `/client/missions` → Mes missions
- `/client/profile` → Mon profil
- `/smartphone/client/missions/create_mission_view` → Créer une mission
- `/smartphone/client/missions/mission_detail_view` → Détail d'une mission

### `admin_routes.dart` — Routes de l'Admin
Routes d'administration :
- `/admin/dashboard` → Tableau de bord admin
- `/admin/users` → Gestion utilisateurs
- `/admin/tasks` → Gestion missions

---

## 🔁 Comment naviguer entre les pages

```dart
// Aller vers une page (simple)
Navigator.pushNamed(context, AppRouteNames.login);
Navigator.pushNamed(context, FreelanceRouteNames.home);
Navigator.pushNamed(context, ClientRouteNames.missions);

// Aller vers une page avec des données (arguments)
Navigator.pushNamed(
  context,
  FreelanceRouteNames.profile,
  arguments: {'userId': 42},  // ← Map avec userId
);

Navigator.pushNamed(
  context,
  ClientRouteNames.missionDetail,
  arguments: 7,  // ← int taskId directement
);

// Remplacer toute la pile de navigation (ex: après connexion)
Navigator.pushNamedAndRemoveUntil(
  context,
  FreelanceRouteNames.home,
  (route) => false,
);
```

---

## ➕ Comment ajouter une nouvelle fonctionnalité

Prenons l'exemple : **"Ajouter la page 'Modifier mon profil' pour le freelance"**

### Étape 1 — Créer le Modèle (si nécessaire)
Si tu as besoin d'une nouvelle structure de données, crée-la dans `models/`.  
Dans notre cas, `UserModel` existe déjà.

### Étape 2 — Ajouter l'endpoint dans `api_endpoints.dart`
```dart
// Dans services/api/api_endpoints.dart
static String updateUserProfile(int userId) => '$usersBase/$userId';
```

### Étape 3 — Ajouter la méthode dans le Service
```dart
// Dans services/api/freelance/freelance_api_service.dart
Future<ApiResponse<UserModel>> updateProfile(int userId, Map<String, dynamic> data) {
  return _apiClient.put<UserModel>(
    endpoint: ApiEndpoints.updateUserProfile(userId),
    body: data,
    parser: (json) => UserModel.fromJson(json as Map<String, dynamic>),
  );
}
```

### Étape 4 — Ajouter la méthode dans le Contrôleur
```dart
// Dans controllers/freelance/profil_controller.dart
Future<bool> updateProfile(int userId, String fullName, String phone) async {
  final response = await FreelanceApiService().updateProfile(userId, {
    'full_name': fullName,
    'phone_number': phone,
  });
  return response.isSuccess;
}
```

### Étape 5 — Créer la Vue
```dart
// Nouveau fichier : views/smartphone/freelance/profile/edit_profile_page.dart
class EditProfilePage extends StatefulWidget {
  final UserModel user;
  // ...
}
```

### Étape 6 — Ajouter la route dans `freelance_routes.dart`
```dart
// 1. Dans FreelanceRouteNames, ajouter la constante
static const String editProfile = '/freelance/profile/edit';

// 2. Dans FreelanceRoutes.generate(), ajouter le case
case FreelanceRouteNames.editProfile:
  return _guardRoute(
    settings: settings,
    requiredRole: UserRole.freelancer,
    builder: () {
      final user = settings.arguments as UserModel;
      return EditProfilePage(user: user);
    },
  );
```

### Étape 7 — Naviguer depuis la Vue existante
```dart
// Dans freelance_profile_page.dart
ElevatedButton(
  onPressed: () => Navigator.pushNamed(
    context,
    FreelanceRouteNames.editProfile,
    arguments: user,
  ),
  child: const Text('Modifier mon profil'),
),
```

---

## 🔌 Comment fonctionne l'API

### Le Client HTTP (`api_core.dart`)
Toutes les requêtes passent par `ApiClient` qui gère :
- Les **headers** (`Authorization: Bearer <token>`)
- La **désérialisation** JSON
- Les **erreurs** réseau et HTTP
- Le **mode mock** pour les tests sans backend

```dart
final ApiClient _apiClient = ApiClient();

// Exemple de requête GET
final response = await _apiClient.get<UserModel>(
  endpoint: ApiEndpoints.userById(42),
  parser: (json) => UserModel.fromJson(json as Map<String, dynamic>),
);

if (response.isSuccess) {
  final user = response.data!;
}
```

### Le mode Mock
Quand `MockData.useMock == true`, aucune requête réseau n'est faite.  
Les données viennent de `services/api/mock_data.dart`.

Pour **activer le backend réel**, mettre `useMock = false` dans `mock_data.dart`.

### Authentification
Le token JWT est stocké dans `ApiClient._authToken` (statique).  
- **Connexion** : `ApiClient.setToken(token)` via `auth_controller.dart`
- **Déconnexion** : `ApiClient.clearToken()`
- **Vérifier si connecté** : `ApiClient.currentToken != null`

---

## 🏗️ Backend (FastAPI)

Le backend tourne sur `localhost:8000`.  
Documentation Swagger : **http://localhost:8000/docs**

### Principales routes backend

| Méthode | URL | Description |
|---------|-----|-------------|
| `POST` | `/api/v1/login/access-token` | Connexion, retourne JWT |
| `POST` | `/api/v1/users/` | Créer un compte |
| `GET` | `/api/v1/users/{id}` | Profil d'un utilisateur |
| `GET` | `/api/v1/tasks/` | Toutes les missions |
| `GET` | `/api/v1/tasks/my-tasks` | Missions du client connecté |
| `POST` | `/api/v1/tasks/` | Créer une mission |
| `GET` | `/api/v1/applications/my-applications` | Candidatures du freelance |
| `POST` | `/api/v1/applications/` | Postuler à une mission |
| `GET` | `/api/v1/statistics/freelancer/{id}` | Stats d'un freelance |
| `GET` | `/api/v1/notifications/` | Notifications de l'utilisateur |

### Changer le backend host

```bash
# Démarrer l'app sur un vrai appareil avec ton IP local
flutter run --dart-define=BACKEND_HOST=192.168.1.50:8000

# Pour Android émulateur
flutter run --dart-define=BACKEND_HOST=10.0.2.2:8000

# Par défaut (simulateur iOS / Web / Linux)
flutter run  # utilise localhost:8000
```

---

## 🛠️ Commandes utiles

```bash
# Lancer l'app (mode développement)
cd freelance_front
flutter run

# Vérifier les erreurs de compilation
flutter analyze

# Lancer les tests
flutter test

# Mettre à jour les dépendances
flutter pub get

# Nettoyer le build (si problèmes bizarres)
flutter clean && flutter pub get
```

---

## ⚠️ Points d'attention connus

### 1. Guard de sécurité désactivé
Dans `freelance_routes.dart` et `client_routes.dart`, la méthode `_guardRoute` ne vérifie pas encore le token JWT.  
**→ Avant la mise en production**, réactiver la vérification de token et de rôle (voir les commentaires `TODO` dans ces fichiers).

### 2. `withOpacity` déprécié
Flutter déprécie `Color.withOpacity()`. Utiliser `Color.withValues(alpha: ...)` à la place.

```dart
// ❌ Déprécié
color: AppColors.accent.withOpacity(0.2)

// ✅ Correct
color: AppColors.accent.withValues(alpha: 0.2)
```

### 3. Profil Freelance — endpoint à corriger
Le `ProfilController` appelle actuellement `/statistics/freelancer/{id}` pour récupérer le profil.  
C'est un endpoint de statistiques, pas de profil.  
**→ À corriger** : utiliser `ApiEndpoints.userById(userId)` ou `ApiEndpoints.userProfile(userId)`.

### 4. Clé `pseudo` dans UserModel
Le backend peut retourner le nom sous `pseudo`, `full_name` ou `fullName`.  
Le `UserModel.fromJson()` gère ces 3 variantes automatiquement.

---

## 📝 Conventions de nommage

| Élément | Convention | Exemple |
|---------|-----------|---------|
| Fichiers Dart | `snake_case` | `freelance_profile_page.dart` |
| Classes | `PascalCase` | `FreelanceProfilePage` |
| Variables | `camelCase` | `userId`, `authController` |
| Constantes de routes | Classe + constante | `FreelanceRouteNames.home` |
| Dossiers | `snake_case` | `freelance/profile/` |
| URLs backend | `kebab-case` | `/my-applications` |

---

## 🔑 Résumé — Ce qu'il faut retenir

> **Quand tu veux modifier une fonctionnalité**, localise d'abord dans quelle couche elle se trouve :
>
> - **Quelque chose ne s'affiche pas bien** → Regarde dans `views/`
> - **Une donnée est mauvaise / manquante** → Regarde dans `controllers/` ou `models/`
> - **Une requête HTTP échoue** → Regarde dans `services/api/` et `api_endpoints.dart`
> - **La navigation ne fonctionne pas** → Regarde dans `routes/`
>
> **Flux de travail standard pour une feature :**
>
> `api_endpoints.dart` → `service/` → `controller/` → `view/` → `routes/`

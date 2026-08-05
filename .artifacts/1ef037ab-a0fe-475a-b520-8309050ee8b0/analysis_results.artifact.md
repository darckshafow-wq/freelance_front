# Analyse du Projet : Freelance Platform

Ce document présente une analyse détaillée de l'architecture, de l'état actuel et des technologies utilisées dans l'application **freelance_front**.

## 🎯 Vue d'ensemble
L'application est une plateforme de mise en relation entre **Clients** et **Freelancers**. Elle permet de créer des missions, d'y postuler, de discuter via un chat temps réel et de gérer l'attribution des tâches.

---

## 🏗️ Architecture Technique (MVC)
Le projet suit une structure modulaire et propre :

### 1. Couche Vue (Views)
- Localisée dans `lib/views/`.
- Séparée par type d'appareil (`smartphone`, `desktop`) et par rôle (`client`, `freelance`, `admin`).
- Utilise des widgets Material Design 3.

### 2. Couche Contrôleur (Controllers)
- Localisée dans `lib/controllers/`.
- Utilise `ChangeNotifier` avec le package `Provider` pour la gestion d'état.
- Gère l'authentification (`AuthController`), les missions (`TaskController`) et les discussions (`ChatController`).

### 3. Couche Service (API)
- Localisée dans `lib/services/api/`.
- `ApiClient` : Gère les requêtes HTTP, l'injection des tokens JWT et le décodage JSON.
- `ApiEndpoints` : Centralise toutes les routes du backend (FastAPI).

### 4. Couche Modèle (Models)
- Localisée dans `lib/models/`.
- Classes de données typées avec parseurs `fromJson`.
- Exemples : `UserModel`, `TaskModel`, `ApplicationModel`, `MessageModel`.

---

## 🚀 État Actuel du Projet

### ✅ Fonctionnalités Implémentées
- **Authentification complète** : Login, Register, vérification OTP.
- **Gestion des Missions** : Création côté client, liste publique côté freelance.
- **Candidatures** : Postuler à une mission avec lettre de motivation et budget.
- **Système de Chat Avancé** :
    - Discussion temps réel entre client et freelance.
    - **Nouveau Workflow** : Attribution ou refus d'une mission directement depuis le chat.
    - Passage automatique en statut "Interview" au premier message du client.
- **Interface Admin** : Dashboard avec statistiques et gestion des utilisateurs/tâches.

### 🛠️ Travaux Récents
- **Refonte Design** : Modernisation du chat client (thème Noir & Jaune).
- **Nettoyage de Code** : Suppression des avertissements (lint), suppression du code mort et passage à l'API `withValues` de Flutter.
- **Sécurisation** : Correction des crashs potentiels liés aux IDs et aux valeurs nulles.

---

## 📦 Stack Technologique
- **Frontend** : Flutter 3.x (Dart).
- **Backend** : FastAPI (Python) tournant sur `localhost:8000`.
- **Base de données** : PostgreSQL (gérée par le backend).
- **Gestion d'état** : Provider.
- **Navigation** : Navigator 1.0 (nommé) & GoRouter.
- **Composants clés** : `google_maps_flutter`, `fl_chart`, `shared_preferences`.

---

## 💡 Recommandations / Prochaines étapes
1. **Tests Unitaires** : Augmenter la couverture de tests dans le dossier `test/`.
2. **Gestion d'erreurs** : Poursuivre l'unification des messages d'erreur via `ApiResponse`.
3. **WebSockets** : Stabiliser la connexion WS pour les notifications push en plus du chat.

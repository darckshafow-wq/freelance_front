import 'package:flutter/foundation.dart';

class ApiEndpoints {
  // ===========================================================================
  // CONFIGURATION DE CONNEXION (IMPORTANT POUR LE TÉLÉPHONE RÉEL)
  // ===========================================================================
  
  // IP de votre machine locale (à ajuster si nécessaire)
  static const String _pcIP = '10.32.155.48'; 

  static String get defaultBaseUrl {
    // Si on lance sur navigateur web sur le PC
    if (kIsWeb) {
      return 'http://localhost:8000/api/v1';
    }
    // Si on lance sur un téléphone réel ou émulateur
    // On utilise l'IP du PC pour que le téléphone puisse le voir sur le réseau
    return 'http://$_pcIP:8000/api/v1';
  }

  // Permet de passer l'URL au lancement si besoin : --dart-define=API_BASE_URL=...
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static String get activeBaseUrl {
    if (baseUrl.isNotEmpty) return baseUrl;
    return defaultBaseUrl;
  }

  static String resolveEndpoint(String endpoint) {
    final normalized = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    return '$activeBaseUrl$normalized';
  }

  // ==========================================
  // AUTHENTICATION & PROFIL
  // ==========================================
  static String get authRegister => resolveEndpoint('/auth/register');
  static String get authLogin => resolveEndpoint('/auth/login');
  static String get authEnable2FA => resolveEndpoint('/auth/enable-2fa');
  static String get authVerify2FA => resolveEndpoint('/auth/verify-2fa');
  static String get authDisable2FA => resolveEndpoint('/auth/disable-2fa');
  static String get authLoginTOTP => resolveEndpoint('/auth/login-totp');
  static String get authPwdResetReq => resolveEndpoint('/auth/password-reset-request');
  static String get authPwdResetConf => resolveEndpoint('/auth/password-reset-confirm');
  
  static String get usersMe => resolveEndpoint('/users/me');
  static String get usersMeProfile => resolveEndpoint('/users/me/profile');
  static String get usersMePersonal => resolveEndpoint('/users/me/personal');

  // ==========================================
  // CLIENT
  // ==========================================
  static String get clientProjects => resolveEndpoint('/client/projects');
  static String get clientPublicProjects => resolveEndpoint('/client/public-projects');
  static String get clientCategories => resolveEndpoint('/client/categories');
  static String get clientConversations => resolveEndpoint('/client/conversations');
  static String clientProjectCancel(int id) => resolveEndpoint('/client/projects/$id/cancel');
  static String clientProjectValidate(int id) => resolveEndpoint('/client/projects/$id/validate');
  static String clientProjectDirectOffer(int id) => resolveEndpoint('/client/projects/$id/direct-offer');
  
  static String get clientDirectOffersSent => resolveEndpoint('/client/direct-offers/sent');
  static String get clientProposals => resolveEndpoint('/client/proposals');
  static String clientProposalAccept(int id) => resolveEndpoint('/client/proposals/$id/accept');
  static String clientProposalFreelanceProfile(int id) => resolveEndpoint('/client/proposals/$id/freelance-profile');
  static String clientProposalTimeline(int id) => resolveEndpoint('/client/proposals/$id/timeline');
  
  static String get clientFreelancers => resolveEndpoint('/client/freelancers'); // Annuaire des freelances
  static String clientFreelanceDetail(int id) => resolveEndpoint('/client/freelancers/$id'); // Détail d'un freelance
  
  static String get clientStats => resolveEndpoint('/client/stats');
  static String get clientFeedback => resolveEndpoint('/client/feedback');
  static String get clientFeedbackMyTickets => resolveEndpoint('/client/feedback/my-tickets');
  
  static String get clientReports => resolveEndpoint('/client/reports');
  static String get clientReportsFiled => resolveEndpoint('/client/reports/filed');

  // ==========================================
  // FREELANCE
  // ==========================================
  static String get freelanceProjects => resolveEndpoint('/freelance/projects');
  static String freelanceProjectProposals(int id) => resolveEndpoint('/freelance/projects/$id/proposals');
  static String get freelanceProposals => resolveEndpoint('/freelance/proposals');
  static String freelanceProposalCancel(int id) => resolveEndpoint('/freelance/proposals/$id/cancel');
  
  static String get freelanceDirectOffers => resolveEndpoint('/freelance/direct-offers');
  static String freelanceDirectOfferAccept(int id) => resolveEndpoint('/freelance/direct-offers/$id/accept');
  static String freelanceDirectOfferReject(int id) => resolveEndpoint('/freelance/direct-offers/$id/reject');
  
  static String freelanceProjectArrived(int id) => resolveEndpoint('/freelance/projects/$id/arrived');
  static String freelanceProjectFinished(int id) => resolveEndpoint('/freelance/projects/$id/finished');
  
  static String get freelanceStats => resolveEndpoint('/freelance/stats');
  static String get freelanceReports => resolveEndpoint('/freelance/reports');
  static String get freelanceReportsFiled => resolveEndpoint('/freelance/reports/filed');
  static String get freelanceFeedback => resolveEndpoint('/freelance/feedback');
  static String get freelanceFeedbackMyTickets => resolveEndpoint('/freelance/feedback/my-tickets');
  static String get freelanceConversations => resolveEndpoint('/freelance/conversations');
  static String get freelanceProjectsNearby => resolveEndpoint('/freelance/projects/nearby');
  static String freelanceProjectDetail(int id) => resolveEndpoint('/freelance/projects/$id');

  // ==========================================
  // ADMIN
  // ==========================================
  static String get adminOverview => resolveEndpoint('/admin/overview');
  static String get adminUsers => resolveEndpoint('/admin/users');
  static String adminUserSuspend(int id) => resolveEndpoint('/admin/users/$id/suspend');
  static String adminUserActivate(int id) => resolveEndpoint('/admin/users/$id/activate');
  static String adminUserVerifyIdentity(int id) => resolveEndpoint('/admin/users/$id/verify-identity');
  
  static String get adminProjects => resolveEndpoint('/admin/projects');
  static String adminProjectDelete(int id) => resolveEndpoint('/admin/projects/$id');
  
  static String get adminReports => resolveEndpoint('/admin/reports');
  static String adminReportResolve(int id) => resolveEndpoint('/admin/reports/$id/resolve');
  
  static String get adminStats => resolveEndpoint('/admin/stats');
  static String get adminAuditLogs => resolveEndpoint('/admin/audit-logs');
  
  static String get adminSystemWarnings => resolveEndpoint('/admin/system-warnings');
  static String adminSystemWarningResolve(int id) => resolveEndpoint('/admin/system-warnings/$id/resolve');
  
  static String get adminFeedbacksPending => resolveEndpoint('/admin/feedbacks/pending');
  static String adminFeedbackReply(int id) => resolveEndpoint('/admin/feedbacks/$id/reply');
  
  static String get adminCategories => resolveEndpoint('/admin/categories');
  static String adminCategoryUpdate(int id) => resolveEndpoint('/admin/categories/$id');
  
  static String get adminBroadcast => resolveEndpoint('/admin/broadcast');

  // ==========================================
  // MESSAGES & CHAT (HTTP & WebSockets)
  // ==========================================
  static String projectDetail(int id) => resolveEndpoint('/projects/$id');
  static String projectMessages(int id) => resolveEndpoint('/projects/$id/messages');
  static String projectMessagesRead(int id) => resolveEndpoint('/projects/$id/messages/read');
  
  static String wsChat(int id) {
    final wsBase = activeBaseUrl
        .replaceFirst('https://', 'wss://')
        .replaceFirst('http://', 'ws://');
    return '$wsBase/ws/chat/$id';
  }

  // ==========================================
  // NOTIFICATIONS
  // ==========================================
  static String get notifications => resolveEndpoint('/notifications');
  static String notification(int id) => resolveEndpoint('/notifications/$id');
  static String notificationRead(int id) => resolveEndpoint('/notifications/$id/read');
  static String get notificationsReadAll => resolveEndpoint('/notifications/read/all');
  static String get notificationsUnreadCount => resolveEndpoint('/notifications/stats/unread');

  // ==========================================
  // REVIEWS
  // ==========================================
  static String get reviews => resolveEndpoint('/reviews/');

  // ==========================================
  // LOCATIONS
  // ==========================================
  static String get locationsCountries => resolveEndpoint('/locations/countries');
  static String locationsCities(int countryId) => resolveEndpoint('/locations/countries/$countryId/cities');
  static String locationsDistricts(int cityId) => resolveEndpoint('/locations/cities/$cityId/districts');
  static String locationCountryFull(int countryId) => resolveEndpoint('/locations/countries/$countryId/full');

  // ADMIN LOCATIONS
  static String get adminLocationsCountries => resolveEndpoint('/admin/locations/countries');
  static String adminLocationCountryDelete(int id) => resolveEndpoint('/admin/locations/countries/$id');
  static String get adminLocationsCities => resolveEndpoint('/admin/locations/cities');
  static String adminLocationCityDelete(int id) => resolveEndpoint('/admin/locations/cities/$id');
  static String get adminLocationsDistricts => resolveEndpoint('/admin/locations/districts');
  static String adminLocationDistrictDelete(int id) => resolveEndpoint('/admin/locations/districts/$id');

  // ==========================================
  // UPLOAD
  // ==========================================
  static String get uploadImage => resolveEndpoint('/upload/image');
}

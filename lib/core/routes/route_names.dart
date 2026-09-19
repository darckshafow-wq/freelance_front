class RouteNames {
  static const String landing = '/welcome';
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String otpVerification = '/otp-verification';
  static const String resetPassword = '/reset-password';
  
  static const String desktopRestriction = '/desktop-restriction';

  // Admin
  static const String adminDashboard = '/admin/dashboard';
  static const String adminUsers = '/admin/users';
  static const String adminUserDetail = '/admin/user/:userId';
  static const String adminProjects = '/admin/projects';
  static const String adminProjectDetail = '/admin/project/:projectId';
  static const String adminBroadcast = '/admin/broadcast/send';
  static const String adminBroadcastsList = '/admin/broadcast/list';
  static const String adminWarnings = '/admin/warnings';
  static const String adminAuditLogs = '/admin/audit-logs';
  static const String adminReports = '/admin/reports';
  static const String adminReviews = '/admin/reviews';
  static const String adminCategories = '/admin/categories';
  static const String adminFeedback = '/admin/feedback';
  static const String adminLocations = '/admin/locations';
  static const String adminFinancials = '/admin/financials';
  static const String adminSettings = '/admin/settings';
  static const String adminCountryDetail = '/admin/locations/country/:countryId';
  static const String adminCityDetail = '/admin/locations/city/:cityId';
  static const String adminDistricts = '/admin/districts/:cityId';

  // Client
  static const String clientDashboard = '/client/dashboard';
  static const String clientProjects = '/client/projects';
  static const String clientCreateProject = '/client/projects/create';
  static const String clientProposals = '/client/proposals';
  static const String clientFreelanceSearch = '/client/search';
  static const String clientProfile = '/client/profile';
  static const String clientReviews = '/client/profile/reviews';
  static const String clientReviewDetail = '/client/profile/reviews/detail';
  static const String clientNotifications = '/client/notifications';
  static const String clientSupport = '/client/support';
  static const String clientChat = '/client/chat';
  static const String clientFreelanceDetail = '/client/freelance/:freelanceId';
  static const String clientConversationDetail = '/client/conversation/:conversationId';
  static const String clientProjectDetail = '/client/project/:projectId';
  static const String clientOwnedProjectDetail = '/client/my-project/:projectId';
  static const String clientProjectProposals = '/client/project/proposals/:projectId';

  // Freelance
  static const String freelanceDashboard = '/freelance/dashboard';
  static const String freelanceProjects = '/freelance/projects';
  static const String freelanceProposals = '/freelance/proposals';
  static const String freelanceNotifications = '/freelance/notifications';
  static const String freelanceSupport = '/freelance/support';
  static const String freelanceChat = '/freelance/chat';
  static const String freelanceConversationDetail = '/freelance/chat/detail/:conversationId';
  static const String freelanceProfile = '/freelance/profile';
  static const String freelanceProjectDetail = '/freelance/project/:projectId';
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:freelance_front/app/smartphone/common/auth/landing_view.dart';
import 'package:freelance_front/app/smartphone/common/auth/splash_view.dart';
import 'package:freelance_front/app/smartphone/common/auth/login_view.dart';
import 'package:freelance_front/app/smartphone/common/auth/register_view.dart';
import 'package:freelance_front/app/smartphone/common/auth/forgot_password_view.dart';
import 'package:freelance_front/app/smartphone/common/auth/otp_verification_view.dart';
import 'package:freelance_front/app/smartphone/common/auth/reset_password_view.dart';

import 'package:freelance_front/app/desktop/admin/home/admin_main_view.dart';
import 'package:freelance_front/app/desktop/admin/dashboard/admin_dashboard_view.dart';
import 'package:freelance_front/app/desktop/admin/feedback/admin_feedback_view.dart';
import 'package:freelance_front/app/desktop/admin/users/admin_users_list_view.dart';
import 'package:freelance_front/app/desktop/admin/users/admin_user_detail_view.dart';
import 'package:freelance_front/app/desktop/admin/projects/admin_projects_list_view.dart';
import 'package:freelance_front/app/desktop/admin/projects/admin_project_detail_view.dart';
import 'package:freelance_front/app/desktop/admin/audit/admin_audit_logs_view.dart';
import 'package:freelance_front/app/desktop/admin/broadcast/admin_broadcast_view.dart';
import 'package:freelance_front/app/desktop/admin/broadcast/admin_broadcasts_list_view.dart';
import 'package:freelance_front/app/desktop/admin/reports/admin_reports_view.dart';
import 'package:freelance_front/app/desktop/admin/reviews/admin_reviews_view.dart';
import 'package:freelance_front/app/desktop/admin/categories/admin_categories_view.dart';
import 'package:freelance_front/app/desktop/admin/warnings/admin_warnings_view.dart';
import 'package:freelance_front/app/desktop/admin/locations/admin_locations_view.dart';
import 'package:freelance_front/app/desktop/admin/locations/admin_country_detail_view.dart';
import 'package:freelance_front/app/desktop/admin/locations/admin_districts_view.dart';
import 'package:freelance_front/app/desktop/admin/financials/admin_financials_view.dart';
import 'package:freelance_front/app/desktop/admin/settings/admin_settings_view.dart';
import 'package:freelance_front/app/desktop/common/errors/desktop_restriction_view.dart';

import 'package:freelance_front/app/smartphone/common/support/support_view.dart';
import 'package:freelance_front/app/smartphone/client/home/client_main_view.dart';
import 'package:freelance_front/app/smartphone/client/home/client_home_view.dart';
import 'package:freelance_front/app/smartphone/client/projects/client_project_list_view.dart';
import 'package:freelance_front/app/smartphone/client/projects/project_create_stepper_view.dart';
import 'package:freelance_front/app/smartphone/client/projects/client_proposals_view.dart';
import 'package:freelance_front/app/smartphone/client/projects/client_project_detail_view.dart';
import 'package:freelance_front/app/smartphone/client/freelance/freelance_directory_view.dart';
import 'package:freelance_front/app/smartphone/client/chat/client_chat_list_view.dart';
import 'package:freelance_front/app/smartphone/client/chat/client_conversation_detail_view.dart';
import 'package:freelance_front/app/smartphone/client/notifications/client_notifications_view.dart';
import 'package:freelance_front/app/smartphone/client/profile/client_profile_view.dart';
import 'package:freelance_front/app/smartphone/client/profile/client_review_detail_view.dart';
import 'package:freelance_front/core/models/common/review_model.dart';
import 'package:freelance_front/core/models/common/project_model.dart';

import 'package:freelance_front/app/smartphone/freelance/home/freelance_main_view.dart' as free_main;
import 'package:freelance_front/app/smartphone/freelance/home/freelance_home_view.dart' as free_home;
import 'package:freelance_front/app/smartphone/freelance/projects/freelance_proposals_view.dart' as free_props;
import 'package:freelance_front/app/smartphone/freelance/chat/freelance_chat_list_view.dart' as free_chat;
import 'package:freelance_front/app/smartphone/freelance/chat/freelance_conversation_detail_view.dart' as free_chat_detail;
import 'package:freelance_front/app/smartphone/freelance/profile/freelance_profile_view.dart' as free_prof;
import 'package:freelance_front/app/smartphone/freelance/projects/freelance_project_detail_view.dart' as free_detail;
import 'package:freelance_front/app/smartphone/freelance/notifications/freelance_notifications_view.dart' as free_notif;

import 'package:freelance_front/app/smartphone/freelance/support/freelance_feedback_view.dart' as free_support;

import 'route_names.dart';
import 'package:freelance_front/core/controllers/common/auth_controller.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
  static final GlobalKey<NavigatorState> _adminShellKey = GlobalKey<NavigatorState>(debugLabel: 'admin_shell');
  static final GlobalKey<NavigatorState> _clientShellKey = GlobalKey<NavigatorState>(debugLabel: 'client_shell');
  static final GlobalKey<NavigatorState> _freelanceShellKey = GlobalKey<NavigatorState>(debugLabel: 'freelance_shell');

  static GoRouter? _router;

  static GoRouter router(AuthController authController) {
    _router ??= GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: RouteNames.splash,
      refreshListenable: authController,
      debugLogDiagnostics: true,
      redirect: (context, state) {
        final bool loggedIn = authController.isAuthenticated;
        final String? role = authController.userRole;
        final String location = state.uri.path;
        
        final size = MediaQuery.of(context).size;
        final isDesktop = size.width > 900;

        final bool isAuthRoute = location == RouteNames.landing || 
                                location == RouteNames.login || 
                                location == RouteNames.register || 
                                location == RouteNames.forgotPassword || 
                                location == RouteNames.resetPassword || 
                                location == RouteNames.otpVerification;

        if (location == RouteNames.splash) return null;

        if (!loggedIn && !isAuthRoute) return RouteNames.login;

        if (loggedIn && isDesktop && (role == 'CLIENT' || role == 'FREELANCE')) {
          if (location != RouteNames.desktopRestriction) return RouteNames.desktopRestriction;
          return null;
        }

        if (loggedIn && isAuthRoute) {
          if (role == 'ADMIN') return RouteNames.adminDashboard;
          if (role == 'CLIENT') return RouteNames.clientDashboard;
          if (role == 'FREELANCE') return RouteNames.freelanceDashboard;
        }

        if (loggedIn) {
          if (location.startsWith('/admin') && role != 'ADMIN') return RouteNames.landing;
          if (location.startsWith('/client') && role != 'CLIENT') return RouteNames.landing;
          if (location.startsWith('/freelance') && role != 'FREELANCE') return RouteNames.landing;
        }

        return null;
      },
      routes: [
        GoRoute(path: RouteNames.splash, name: 'splash', builder: (context, state) => const SplashView()),
        GoRoute(path: RouteNames.landing, name: 'landing', builder: (context, state) => const LandingView()),
        GoRoute(path: RouteNames.login, name: 'login', builder: (context, state) => const LoginView()),
        GoRoute(path: RouteNames.register, name: 'register', builder: (context, state) => const RegisterView()),
        GoRoute(path: RouteNames.forgotPassword, name: 'forgotPassword', builder: (context, state) => const ForgotPasswordView()),
        GoRoute(path: RouteNames.resetPassword, name: 'resetPassword', builder: (context, state) => const ResetPasswordView()),
        GoRoute(path: RouteNames.desktopRestriction, name: 'desktopRestriction', builder: (context, state) => const DesktopRestrictionView()),
        GoRoute(
          path: RouteNames.otpVerification,
          name: 'otpVerification',
          builder: (context, state) {
            final extras = state.extra as Map<String, dynamic>?;
            return OtpVerificationView(
              email: extras?['email'] ?? '',
              type: extras?['type'] ?? 'verification',
            );
          },
        ),

        // Admin Shell
        ShellRoute(
          navigatorKey: _adminShellKey,
          builder: (context, state, child) => AdminMainView(key: const ValueKey('AdminMainView'), child: child),
          routes: [
            _fadeRoute(path: RouteNames.adminDashboard, name: 'adminDashboard', builder: (ctx, s) => const AdminDashboardView()),
            _fadeRoute(path: RouteNames.adminUsers, name: 'adminUsers', builder: (ctx, s) => const AdminUsersListView()),
            _fadeRoute(path: RouteNames.adminProjects, name: 'adminProjects', builder: (ctx, s) => const AdminProjectsListView()),
            _fadeRoute(path: RouteNames.adminFeedback, name: 'adminFeedback', builder: (ctx, s) => const AdminFeedbackView()),
            _fadeRoute(path: RouteNames.adminBroadcast, name: 'adminBroadcast', builder: (ctx, s) => const AdminBroadcastView(isDialog: false)),
            _fadeRoute(path: RouteNames.adminBroadcastsList, name: 'adminBroadcastsList', builder: (ctx, s) => const AdminBroadcastsListView()),
            _fadeRoute(path: RouteNames.adminReports, name: 'adminReports', builder: (ctx, s) => const AdminReportsView()),
            _fadeRoute(path: RouteNames.adminReviews, name: 'adminReviews', builder: (ctx, s) => const AdminReviewsView()),
            _fadeRoute(path: RouteNames.adminCategories, name: 'adminCategories', builder: (ctx, s) => const AdminCategoriesView()),
            _fadeRoute(path: RouteNames.adminWarnings, name: 'adminWarnings', builder: (ctx, s) => const AdminWarningsView()),
            _fadeRoute(path: RouteNames.adminUserDetail, name: 'adminUserDetail', builder: (ctx, s) => AdminUserDetailView(id: s.pathParameters['userId'] ?? '0')),
            _fadeRoute(path: RouteNames.adminProjectDetail, name: 'adminProjectDetail', builder: (ctx, s) => AdminProjectDetailView(id: s.pathParameters['projectId'] ?? '0')),
            _fadeRoute(path: RouteNames.adminAuditLogs, name: 'adminAuditLogs', builder: (ctx, s) => const AdminAuditLogsView()),
            _fadeRoute(path: RouteNames.adminLocations, name: 'adminLocations', builder: (ctx, s) => const AdminLocationsView()),
            _fadeRoute(path: RouteNames.adminFinancials, name: 'adminFinancials', builder: (ctx, s) => const AdminFinancialsView()),
            _fadeRoute(path: RouteNames.adminSettings, name: 'adminSettings', builder: (ctx, s) => const AdminSettingsView()),
            _fadeRoute(path: RouteNames.adminCountryDetail, name: 'adminCountryDetail', builder: (ctx, s) => AdminCountryDetailView(countryId: s.pathParameters['countryId'] ?? '0')),
            _fadeRoute(path: RouteNames.adminCityDetail, name: 'adminCityDetail', builder: (ctx, s) => AdminDistrictsView(cityId: s.pathParameters['cityId'] ?? '0')),
            _fadeRoute(path: RouteNames.adminDistricts, name: 'adminDistricts', builder: (ctx, s) => AdminDistrictsView(cityId: s.pathParameters['cityId'] ?? '0')),
          ],
        ),

        // Client Shell
        ShellRoute(
          navigatorKey: _clientShellKey,
          builder: (context, state, child) => ClientMainView(key: const ValueKey('ClientMainView'), child: child),
          routes: [
            GoRoute(path: RouteNames.clientDashboard, name: 'clientDashboard', builder: (context, state) => const ClientHomeView()),
            GoRoute(path: RouteNames.clientProjects, name: 'clientProjects', builder: (context, state) => const ClientProjectListView()),
            GoRoute(path: RouteNames.clientChat, name: 'clientChat', builder: (context, state) => const ClientChatListView()),
            GoRoute(path: RouteNames.clientProfile, name: 'clientProfile', builder: (context, state) => const ClientProfileView()),
            GoRoute(path: RouteNames.clientFreelanceSearch, name: 'clientFreelanceSearch', builder: (context, state) => const FreelanceDirectoryView()),
            GoRoute(path: RouteNames.clientProposals, name: 'clientProposals', builder: (context, state) => const ClientProposalsView()),
          ],
        ),

        // Freelance Shell
        ShellRoute(
          navigatorKey: _freelanceShellKey,
          builder: (context, state, child) => free_main.FreelanceMainView(key: const ValueKey('FreelanceMainView'), child: child),
          routes: [
            GoRoute(path: RouteNames.freelanceDashboard, name: 'freelanceDashboard', builder: (context, state) => const free_home.FreelanceHomeView()),
            GoRoute(path: RouteNames.freelanceProposals, name: 'freelanceProposals', builder: (context, state) => const free_props.FreelanceProposalsView()),
            GoRoute(path: RouteNames.freelanceChat, name: 'freelanceChat', builder: (context, state) => const free_chat.FreelanceChatListView()),
            GoRoute(path: RouteNames.freelanceProfile, name: 'freelanceProfile', builder: (context, state) => const free_prof.FreelanceProfileView()),
            GoRoute(path: RouteNames.freelanceNotifications, name: 'freelanceNotifications', builder: (context, state) => const free_notif.FreelanceNotificationsView()),
            GoRoute(path: RouteNames.freelanceSupport, name: 'freelanceSupport', builder: (context, state) => const free_support.FreelanceFeedbackView()),
          ],
        ),

        GoRoute(path: RouteNames.clientCreateProject, name: 'clientCreateProject', builder: (context, state) => const ProjectCreateStepperView()),
        GoRoute(
          path: RouteNames.freelanceProjectDetail,
          name: 'freelanceProjectDetail',
          builder: (context, state) {
            ProjectModel? project;
            if (state.extra is ProjectModel) {
              project = state.extra as ProjectModel;
            }
            return free_detail.FreelanceProjectDetailView(
              id: state.pathParameters['projectId'] ?? '0',
              project: project,
            );
          },
        ),
        GoRoute(
          path: RouteNames.clientProjectDetail,
          name: 'clientProjectDetail',
          builder: (context, state) {
            ProjectModel? project;
            if (state.extra is ProjectModel) {
              project = state.extra as ProjectModel;
            }
            return ClientProjectDetailView(
              id: state.pathParameters['projectId'] ?? '0',
              isClientMission: state.uri.queryParameters['owner'] == 'client',
              project: project,
            );
          },
        ),
        GoRoute(path: RouteNames.freelanceConversationDetail, name: 'freelanceConversationDetail', builder: (context, state) => free_chat_detail.FreelanceConversationDetailView(id: state.pathParameters['conversationId'] ?? '0')),
        GoRoute(path: RouteNames.clientNotifications, name: 'clientNotifications', builder: (context, state) => const ClientNotificationsView()),
        GoRoute(path: RouteNames.clientSupport, name: 'clientSupport', builder: (context, state) => const SupportView()),
        GoRoute(path: RouteNames.clientReviewDetail, name: 'clientReviewDetail', builder: (context, state) => ClientReviewDetailView(review: state.extra! as ReviewModel)),
        GoRoute(path: RouteNames.clientConversationDetail, name: 'clientConversationDetail', builder: (context, state) => ClientConversationDetailView(id: state.pathParameters['conversationId'] ?? '0')),
      ],
    );
    return _router!;
  }

  static GoRoute _fadeRoute({required String path, required String name, required Widget Function(BuildContext, GoRouterState) builder}) {
    return GoRoute(
      path: path,
      name: name,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: builder(context, state),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
            child: child,
          );
        },
      ),
    );
  }
}

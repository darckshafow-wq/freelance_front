import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:freelance_front/app/smartphone/common/auth/landing_view.dart';
import 'package:freelance_front/app/smartphone/common/auth/login_view.dart';
import 'package:freelance_front/app/smartphone/common/auth/register_view.dart';
import 'package:freelance_front/app/smartphone/common/auth/forgot_password_view.dart';
import 'package:freelance_front/app/smartphone/common/auth/otp_verification_view.dart';
import 'package:freelance_front/app/smartphone/common/auth/reset_password_view.dart';
import 'package:freelance_front/app/smartphone/freelance/projects/project_list_view.dart';
import 'package:freelance_front/app/desktop/admin/dashboard/admin_dashboard_view.dart';
import 'package:freelance_front/app/desktop/admin/feedback/admin_feedback_view.dart';
import 'package:freelance_front/app/smartphone/client/support/client_feedback_view.dart';
import 'package:freelance_front/app/smartphone/client/home/client_main_view.dart';
import 'package:freelance_front/app/smartphone/client/home/client_home_view.dart';
import 'package:freelance_front/app/smartphone/client/projects/client_project_list_view.dart';
import 'package:freelance_front/app/smartphone/client/projects/project_create_stepper_view.dart';
import 'package:freelance_front/app/smartphone/client/projects/client_proposals_view.dart';
import 'package:freelance_front/app/smartphone/client/projects/client_project_detail_view.dart';
import 'package:freelance_front/app/smartphone/client/projects/proposal_list_view.dart';
import 'package:freelance_front/app/smartphone/client/freelance/freelance_directory_view.dart';
import 'package:freelance_front/app/smartphone/client/freelance/freelance_detail_view.dart';
import 'package:freelance_front/app/smartphone/client/chat/client_chat_list_view.dart';
import 'package:freelance_front/app/smartphone/client/chat/client_conversation_detail_view.dart';
import 'package:freelance_front/app/smartphone/client/notifications/client_notifications_view.dart';
import 'package:freelance_front/app/smartphone/client/profile/client_profile_view.dart';
import 'package:freelance_front/app/smartphone/client/profile/client_reviews_view.dart';
import 'package:freelance_front/app/smartphone/client/profile/client_review_detail_view.dart';
import 'package:freelance_front/core/models/common/review_model.dart';
import 'route_names.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RouteNames.landing,
    routes: [
      // Auth & Common
      GoRoute(
        path: RouteNames.landing,
        name: RouteNames.landing,
        builder: (context, state) => const LandingView(),
      ),
      GoRoute(
        path: RouteNames.login,
        name: RouteNames.login,
        builder: (context, state) => const LoginView(),
      ),
      GoRoute(
        path: RouteNames.register,
        name: RouteNames.register,
        builder: (context, state) => const RegisterView(),
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        name: RouteNames.forgotPassword,
        builder: (context, state) => const ForgotPasswordView(),
      ),
      GoRoute(
        path: RouteNames.otpVerification,
        name: RouteNames.otpVerification,
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>?;
          return OtpVerificationView(
            email: extras?['email'] ?? '',
            type: extras?['type'] ?? 'verification',
          );
        },
      ),
      GoRoute(
        path: RouteNames.resetPassword,
        name: RouteNames.resetPassword,
        builder: (context, state) => const ResetPasswordView(),
      ),
      GoRoute(
        path: RouteNames.projects,
        name: RouteNames.projects,
        builder: (context, state) => const ProjectListView(),
      ),
      GoRoute(
        path: RouteNames.adminDashboard,
        name: RouteNames.adminDashboard,
        builder: (context, state) => const AdminDashboardView(),
      ),
      GoRoute(
        path: RouteNames.adminFeedback,
        name: RouteNames.adminFeedback,
        builder: (context, state) => const AdminFeedbackView(),
      ),

      // Client Shell Route (Contient la Bottom Navigation Bar)
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return ClientMainView(child: child);
        },
        routes: [
          GoRoute(
            path: RouteNames.clientDashboard,
            name: RouteNames.clientDashboard,
            parentNavigatorKey: _shellNavigatorKey,
            builder: (context, state) => const ClientHomeView(),
          ),
          GoRoute(
            path: RouteNames.clientFreelanceSearch,
            name: RouteNames.clientFreelanceSearch,
            parentNavigatorKey: _shellNavigatorKey,
            builder: (context, state) => const FreelanceDirectoryView(),
          ),
          GoRoute(
            path: RouteNames.clientProjects,
            name: RouteNames.clientProjects,
            parentNavigatorKey: _shellNavigatorKey,
            builder: (context, state) => const ClientProjectListView(),
          ),
          GoRoute(
            path: RouteNames.clientProposals,
            name: RouteNames.clientProposals,
            parentNavigatorKey: _shellNavigatorKey,
            builder: (context, state) => const ClientProposalsView(),
          ),
          GoRoute(
            path: RouteNames.clientChat,
            name: RouteNames.clientChat,
            parentNavigatorKey: _shellNavigatorKey,
            builder: (context, state) => const ClientChatListView(),
          ),
          GoRoute(
            path: RouteNames.clientProfile,
            name: RouteNames.clientProfile,
            parentNavigatorKey: _shellNavigatorKey,
            builder: (context, state) => const ClientProfileView(),
          ),
          GoRoute(
            path: RouteNames.clientReviews,
            name: 'clientReviews',
            parentNavigatorKey: _shellNavigatorKey,
            builder: (context, state) => const ClientReviewsView(),
          ),
        ],
      ),

      // Pages Plein Écran (Masquent le ClientMainView et la barre du bas)
      GoRoute(
        path: RouteNames.clientCreateProject,
        name: RouteNames.clientCreateProject,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ProjectCreateStepperView(),
      ),
      GoRoute(
        path: RouteNames.clientProjectDetail,
        name: RouteNames.clientProjectDetail,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => ClientProjectDetailView(
          id: state.pathParameters['id'] ?? '0',
          isClientMission: state.uri.queryParameters['owner'] == 'client',
        ),
      ),
      GoRoute(
        path: RouteNames.clientOwnedProjectDetail,
        name: 'clientOwnedProjectDetail',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => ClientProjectDetailView(
          isClientMission: true,
          id: state.pathParameters['id'] ?? '0',
        ),
      ),
      GoRoute(
        path: RouteNames.clientProjectProposals,
        name: 'clientProjectProposals',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => ProposalListView(
          projectId: int.tryParse(state.pathParameters['id'] ?? '0') ?? 0,
          projectTitle: state.uri.queryParameters['title'] ?? 'Mission',
        ),
      ),
      GoRoute(
        path: RouteNames.clientFreelanceDetail,
        name: RouteNames.clientFreelanceDetail,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => FreelanceDetailView(id: state.pathParameters['id'] ?? '0'),
      ),
      GoRoute(
        path: RouteNames.clientConversationDetail,
        name: RouteNames.clientConversationDetail,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => ClientConversationDetailView(id: state.pathParameters['id'] ?? '0'),
      ),
      GoRoute(
        path: RouteNames.clientNotifications,
        name: RouteNames.clientNotifications,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ClientNotificationsView(),
      ),
      GoRoute(
        path: RouteNames.clientSupport,
        name: RouteNames.clientSupport,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ClientFeedbackView(),
      ),
      GoRoute(
        path: RouteNames.clientReviewDetail,
        name: 'clientReviewDetail',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => ClientReviewDetailView(review: state.extra! as ReviewModel),
      ),
    ],
  );
}
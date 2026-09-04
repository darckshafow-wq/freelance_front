# Implementation Plan - Complete Client Experience (Smartphone)

This plan outlines the implementation of the full Client experience, including project discovery, proposal management, conversational interviewing, freelance directory, and a detailed profile.

## UI/UX Goals
- **Immersive Design**: High-quality imagery, rounded corners (24px+), and consistent spacing.
- **Fluid Animations**: Page transitions and element animations using `flutter_animate`.
- **Intuitive Navigation**: Clear distinction between finding new tasks (Home) and managing existing ones (My Projects).

## Proposed Changes

### Core & Navigation

#### [MODIFY] [route_names.dart](file:///home/shadow-66/freelance_front/lib/core/routes/route_names.dart)
- Add routes: `clientFreelanceDetail`, `clientConversationDetail`, `clientProjectDetail`.

#### [MODIFY] [app_router.dart](file:///home/shadow-66/freelance_front/lib/core/routes/app_router.dart)
- Wire up the new routes to their respective views.

### Feature: Client Views (Smartphone)

#### [NEW] [client_home_view.dart](file:///home/shadow-66/freelance_front/lib/app/smartphone/client/home/client_home_view.dart)
- Centralized feed for all projects/tasks on the platform.
- Search and category filters.

#### [NEW] [client_proposals_view.dart](file:///home/shadow-66/freelance_front/lib/app/smartphone/client/projects/client_proposals_view.dart)
- List of received proposals across all client projects.
- Ability to initiate an "Interview" (Chat).

#### [NEW] [client_project_detail_view.dart](file:///home/shadow-66/freelance_front/lib/app/smartphone/client/projects/client_project_detail_view.dart)
- Detailed view of a project, showing description, budget, and stats.

#### [NEW] [client_conversation_detail_view.dart](file:///home/shadow-66/freelance_front/lib/app/smartphone/client/chat/client_conversation_detail_view.dart)
- Real-time chat interface.
- Action bar to "Award Task" or "Reject".

#### [NEW] [freelance_directory_view.dart](file:///home/shadow-66/freelance_front/lib/app/smartphone/client/freelance/freelance_directory_view.dart)
- List of all freelances with filtering by specialty.
- Direct task assignment capability.

#### [NEW] [freelance_detail_view.dart](file:///home/shadow-66/freelance_front/lib/app/smartphone/client/freelance/freelance_detail_view.dart)
- Comprehensive freelance profile: bio, skills, reviews, portfolio.

#### [NEW] [client_profile_view.dart](file:///home/shadow-66/freelance_front/lib/app/smartphone/client/profile/client_profile_view.dart)
- Stylized client profile with spending stats, project counts, and settings.

### Business Logic

#### [MODIFY] [project_controller.dart](file:///home/shadow-66/freelance_front/lib/core/controllers/common/project_controller.dart)
- Handle "Awarding" projects and transitioning statuses (Pending -> Interview -> Awarded).

#### [NEW] [freelance_controller.dart](file:///home/shadow-66/freelance_front/lib/core/controllers/client/freelance_controller.dart)
- Manage state for the freelance directory and details.

## Verification Plan

### Manual Verification
- Test the full flow: Discover Project -> View Received Proposal -> Start Interview -> Award Project.
- Check the freelance directory and detail view.
- Verify the client profile statistics.

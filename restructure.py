import os
import shutil

moves = [
    # Models -> lib/core/models/
    ('lib/features/auth/models/user_model.dart', 'lib/core/models/common/user_model.dart'),
    ('lib/features/auth/models/user_model.g.dart', 'lib/core/models/common/user_model.g.dart'),
    ('lib/features/profile/models/profile_model.dart', 'lib/core/models/common/profile_model.dart'),
    ('lib/features/profile/models/profile_model.g.dart', 'lib/core/models/common/profile_model.g.dart'),
    ('lib/features/profile/models/notification_model.dart', 'lib/core/models/common/notification_model.dart'),
    ('lib/features/profile/models/notification_model.g.dart', 'lib/core/models/common/notification_model.g.dart'),
    ('lib/features/projects/models/project_model.dart', 'lib/core/models/common/project_model.dart'),
    ('lib/features/projects/models/proposal_model.dart', 'lib/core/models/common/proposal_model.dart'),
    ('lib/features/chat/models/message_model.dart', 'lib/core/models/common/message_model.dart'),
    ('lib/features/reviews/models/review_model.dart', 'lib/core/models/common/review_model.dart'),
    ('lib/features/reports/models/report_model.dart', 'lib/core/models/admin/report_model.dart'),
    ('lib/features/reports/models/feedback_model.dart', 'lib/core/models/admin/feedback_model.dart'),
    ('lib/features/admin_settings/models/category_model.dart', 'lib/core/models/admin/category_model.dart'),
    ('lib/features/admin_dashboard/models/system_warning_model.dart', 'lib/core/models/admin/system_warning_model.dart'),
    ('lib/features/admin_dashboard/models/audit_log_model.dart', 'lib/core/models/admin/audit_log_model.dart'),

    # Controllers -> lib/core/controllers/
    ('lib/features/auth/controllers/auth_controller.dart', 'lib/core/controllers/common/auth_controller.dart'),
    ('lib/features/profile/controllers/profile_controller.dart', 'lib/core/controllers/common/profile_controller.dart'),
    ('lib/features/profile/controllers/notification_controller.dart', 'lib/core/controllers/common/notification_controller.dart'),
    ('lib/features/chat/controllers/message_controller.dart', 'lib/core/controllers/common/message_controller.dart'),
    ('lib/features/projects/controllers/project_controller.dart', 'lib/core/controllers/common/project_controller.dart'),
    ('lib/features/home/home_controller.dart', 'lib/core/controllers/client/home_controller.dart'),

    # Services -> lib/core/services/
    ('lib/features/auth/services/auth_service.dart', 'lib/core/services/common/auth_service.dart'),
    ('lib/features/profile/services/profile_service.dart', 'lib/core/services/common/profile_service.dart'),
    ('lib/features/profile/services/notification_service.dart', 'lib/core/services/common/notification_service.dart'),
    ('lib/features/chat/services/message_service.dart', 'lib/core/services/common/message_service.dart'),
    ('lib/features/projects/services/project_service.dart', 'lib/core/services/client/project_service.dart'),
    ('lib/features/projects/services/freelance_project_service.dart', 'lib/core/services/freelance/freelance_project_service.dart'),
    ('lib/features/home/home_service.dart', 'lib/core/services/client/home_service.dart'),
    
    # Providers
    ('lib/app/config/provider_setup.dart', 'lib/core/providers/provider_setup.dart'),

    # Routes
    ('lib/core/router/app_router.dart', 'lib/core/routes/app_router.dart'),
    ('lib/core/router/route_names.dart', 'lib/core/routes/route_names.dart'),

    # Views -> lib/app/smartphone/common
    ('lib/features/auth/views/landing_view.dart', 'lib/app/smartphone/common/auth/landing_view.dart'),
    ('lib/features/auth/views/login_view.dart', 'lib/app/smartphone/common/auth/login_view.dart'),
    ('lib/features/auth/views/register_view.dart', 'lib/app/smartphone/common/auth/register_view.dart'),

    # Views -> lib/app/smartphone/client
    ('lib/features/home/view/client_main_view.dart', 'lib/app/smartphone/client/home/client_main_view.dart'),
    ('lib/features/home/view/client_dashboard_view.dart', 'lib/app/smartphone/client/home/client_dashboard_view.dart'),
    ('lib/features/projects/views/client_project_list_view.dart', 'lib/app/smartphone/client/projects/client_project_list_view.dart'),
    ('lib/features/projects/views/project_create_stepper_view.dart', 'lib/app/smartphone/client/projects/project_create_stepper_view.dart'),
    ('lib/features/projects/views/proposal_list_view.dart', 'lib/app/smartphone/client/projects/proposal_list_view.dart'),

    # Views -> lib/app/smartphone/freelance
    ('lib/features/projects/views/project_list_view.dart', 'lib/app/smartphone/freelance/projects/project_list_view.dart'),

    # Views -> lib/app/desktop/admin
    ('lib/features/admin_dashboard/views/admin_dashboard_view.dart', 'lib/app/desktop/admin/dashboard/admin_dashboard_view.dart'),
    ('lib/features/admin_settings/views/admin_settings_view.dart', 'lib/app/desktop/admin/settings/admin_settings_view.dart'),
    ('lib/features/admin_financials/views/admin_financials_view.dart', 'lib/app/desktop/admin/financials/admin_financials_view.dart'),
    ('lib/features/admin_users_moderation/views/admin_users_moderation_view.dart', 'lib/app/desktop/admin/users/admin_users_moderation_view.dart'),
    
    # Common views 
    ('lib/features/chat/views/chat_view.dart', 'lib/app/smartphone/common/chat/chat_view.dart'),
]

# Track import replacements
replacements = {}
for old_path, new_path in moves:
    old_pkg = old_path.replace('lib/', 'freelance_front/')
    new_pkg = new_path.replace('lib/', 'freelance_front/')
    replacements[old_pkg] = new_pkg

# Move files
for old_path, new_path in moves:
    if os.path.exists(old_path):
        os.makedirs(os.path.dirname(new_path), exist_ok=True)
        shutil.move(old_path, new_path)
        print(f"Moved {old_path} -> {new_path}")

# Update imports in all dart files
for root, dirs, files in os.walk('lib'):
    for file in files:
        if file.endswith('.dart'):
            filepath = os.path.join(root, file)
            with open(filepath, 'r') as f:
                content = f.read()
            
            new_content = content
            for old_pkg, new_pkg in replacements.items():
                new_content = new_content.replace(f"package:{old_pkg}", f"package:{new_pkg}")
                # Also handle part/part of
                part_old = old_pkg.split('/')[-1]
                part_new = new_pkg.split('/')[-1]
                if part_old != part_new:
                     new_content = new_content.replace(f"part '{part_old}';", f"part '{part_new}';")
            
            if new_content != content:
                with open(filepath, 'w') as f:
                    f.write(new_content)

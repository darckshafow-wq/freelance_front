import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants/app_theme.dart';
// 1. Importe tes contrôleurs ici
import 'controllers/auth/auth_controller.dart';
import 'controllers/shared/feedback_controller.dart';
import 'controllers/admin/admin_controller.dart';
import 'controllers/client/task_controller.dart';
import 'controllers/client/application_controller.dart';
import 'controllers/freelance/task_controller.dart';
import 'controllers/freelance/application_controller.dart';
import 'controllers/freelance/profil_controller.dart';
import 'controllers/shared/notification_controller.dart';
import 'controllers/shared/conversation.dart';
import 'routes/app_router.dart';
import 'services/api/api_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiClient.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => FeedbackController()),
        ChangeNotifierProvider(create: (_) => AdminController()),
        ChangeNotifierProvider(create: (_) => TaskController()),
        ChangeNotifierProvider(create: (_) => ClientApplicationController()),
        ChangeNotifierProvider(create: (_) => FreelanceTaskController()),
        ChangeNotifierProvider(create: (_) => ApplicationController()),
        ChangeNotifierProvider(create: (_) => ProfilController()),
        ChangeNotifierProvider(create: (_) => NotificationController()),
        ChangeNotifierProvider(create: (_) => ChatListController()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Freelance Platform',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: AppRoutes.landing,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}

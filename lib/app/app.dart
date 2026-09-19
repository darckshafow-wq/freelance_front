import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:freelance_front/core/routes/app_router.dart';
import 'package:freelance_front/core/theme/app_theme.dart';
import '../core/providers/provider_setup.dart';

import 'package:freelance_front/core/controllers/common/auth_controller.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: AppProviders.providers,
      child: Consumer<AuthController>(
        builder: (context, authController, _) {
          return MaterialApp.router(
            title: 'FreeFlow Premium',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            routerConfig: AppRouter.router(authController),
          );
        },
      ),
    );
  }
}

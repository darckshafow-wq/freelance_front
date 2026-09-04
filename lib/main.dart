import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/services/common/api_client.dart';
import 'core/services/common/storage_service.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const App();
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final token = await StorageService.readAccessToken();
  if (token != null && token.isNotEmpty) ApiClient.setToken(token);
  runApp(const MyApp());
}

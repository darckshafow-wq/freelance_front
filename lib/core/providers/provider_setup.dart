import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'package:freelance_front/core/controllers/common/auth_controller.dart';
import 'package:freelance_front/core/controllers/common/profile_controller.dart';
import 'package:freelance_front/core/controllers/common/notification_controller.dart';
import 'package:freelance_front/core/controllers/common/project_controller.dart';
import 'package:freelance_front/core/controllers/common/message_controller.dart';
import 'package:freelance_front/core/controllers/client/freelance_controller.dart';

class AppProviders {
  static final List<SingleChildWidget> providers = [
    ChangeNotifierProvider(create: (_) => AuthController()),
    ChangeNotifierProvider(create: (_) => ProfileController()),
    ChangeNotifierProvider(create: (_) => NotificationController()),
    ChangeNotifierProvider(create: (_) => ProjectController()),
    ChangeNotifierProvider(create: (_) => MessageController()),
    ChangeNotifierProvider(create: (_) => FreelanceController()),
  ];
}

import 'package:go_router/go_router.dart';
import 'package:freelance_front/views/smartphone/onbor/landing.dart';

class LandingRouter {
  static const String name = '/landing';
  static const String path = '/landing';

  static GoRoute goRoute = GoRoute(
    path: path,
    name: name,
    builder: (context, state) => const LandingView(),
  );
}

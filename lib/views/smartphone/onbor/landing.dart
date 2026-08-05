import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../constants/app_colors.dart';
import '../../../../controllers/auth/auth_controller.dart';
import '../../../../routes/app_router.dart';
import 'landing_transition_page.dart';

class LandingView extends StatefulWidget {
  const LandingView({super.key});

  @override
  State<LandingView> createState() => _LandingViewState();
}

class _LandingViewState extends State<LandingView>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _restoreSessionAndRedirect();
    });

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _restoreSessionAndRedirect() async {
    if (!mounted) return;

    final authController = context.read<AuthController>();
    await authController.restoreSession();

    if (!mounted) return;

    final currentUser = authController.currentUser;
    if (currentUser != null) {
      Navigator.pushReplacementNamed(context, resolveRedirectRoute(currentUser.role));
    } else {
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isDesktop = size.width > 800;

    final authController = context.watch<AuthController>();
    final hasRestoredSession =
        authController.currentUser != null || authController.isLoading;

    if (hasRestoredSession) {
      return LandingTransitionPage(
        onRestoreSession: () => authController.restoreSession(),
        onNavigateToRoute: (routeName) {
          Navigator.pushReplacementNamed(context, routeName);
        },
      );
    }

    Widget scaffold = Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Background Image (Top Section)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.65,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    'https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExNHJndnBqZ3BqZ3BqZ3BqZ3BqZ3BqZ3BqZ3BqZ3BqZ3BqZ3BqJmVwPXYxX2ludGVybmFsX2dpZl9ieV9pZCZjdD1n/3o7TKP9lG0H7vVvFmU/giphy.gif',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 2. Logo and Brand Name
          Positioned(
            top: size.height * 0.15,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 15,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.bolt_rounded,
                    color: Colors.black,
                    size: 45,
                  ),
                ),
                const SizedBox(height: 25),
                const Text(
                  'FREELANCE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
                const Text(
                  'Expert Platform',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),

          // 3. Bottom White Container with Custom Curve
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: CustomCurveClipper(),
              child: Container(
                height: size.height * 0.45,
                padding: const EdgeInsets.only(top: 60), // Space for the curve
                decoration: const BoxDecoration(color: Colors.white),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        children: [
                          const Text(
                            'WELCOME',
                            style: TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Find your next expert, feel at home\nWhere efficiency meets convenience',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              height: 1.5,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const Spacer(),
                          // Login Button
                          SizedBox(
                            width: double.infinity,
                            height: 60,
                            child: ElevatedButton(
                              onPressed: () =>
                                  Navigator.pushNamed(context, AppRouteNames.login),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    AppColors.primary, // Jaune primaire
                                foregroundColor: Colors.black, // Texte noir
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Sign Up Button
                          SizedBox(
                            width: double.infinity,
                            height: 60,
                            child: TextButton(
                              onPressed: () =>
                                  Navigator.pushNamed(context, AppRouteNames.register),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: const BorderSide(
                                    color: Colors.black12,
                                    width: 1.5,
                                  ), // Ajout d'une bordure subtile
                                ),
                              ),
                              child: const Text(
                                'Sign Up',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (isDesktop) {
      return Scaffold(
        backgroundColor: Colors.grey[200],
        body: Center(
          child: Container(
            width: 450,
            height: 800, // Fixed height to maintain proportions
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
              borderRadius: BorderRadius.circular(30),
            ),
            clipBehavior: Clip.antiAlias,
            child: scaffold,
          ),
        ),
      );
    }
    return scaffold;
  }
}

class CustomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, 50); // Start point
    path.quadraticBezierTo(
      size.width / 2,
      0,
      size.width,
      50,
    ); // Curve to top middle then down
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

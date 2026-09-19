import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:freelance_front/core/constants/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:freelance_front/core/controllers/common/auth_controller.dart';
import 'package:go_router/go_router.dart';
import 'package:freelance_front/core/routes/route_names.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with SingleTickerProviderStateMixin {
  bool _isNavigated = false;

  @override
  void initState() {
    super.initState();
    _handleStartup();
  }

  Future<void> _handleStartup() async {
    final auth = context.read<AuthController>();
    
    // We start auth initialization immediately
    final authInitFuture = auth.init();
    
    // Duration for the "Souffle" (Premium feel)
    final stopwatch = Stopwatch()..start();
    
    await authInitFuture;
    
    final elapsed = stopwatch.elapsedMilliseconds;
    final int minDuration = 3200; // Total duration to appreciate vortex

    if (elapsed < minDuration) {
      await Future.delayed((minDuration - elapsed).ms);
    }

    if (mounted && !_isNavigated) {
      _isNavigated = true;
      // Smooth fade to next screen
      _navigateToNext(auth);
    }
  }

  void _navigateToNext(AuthController auth) {
    if (auth.isAuthenticated) {
      final role = auth.userRole;
      if (role == 'ADMIN') context.go('/admin/dashboard');
      else if (role == 'CLIENT') context.go('/client/dashboard');
      else if (role == 'FREELANCE') context.go('/freelance/dashboard');
    } else {
      context.go(RouteNames.landing);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Vortex de fond (Plus lent et hypnotique)
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                _vortexRing(450, 0.01, 15.seconds, true),
                _vortexRing(360, 0.03, 10.seconds, false),
                _vortexRing(270, 0.05, 7.seconds, true),
              ],
            ),
          ),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Bolt central
                Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 80,
                        offset: const Offset(0, 30),
                      )
                    ],
                  ),
                  child: const Icon(
                    Icons.bolt_rounded,
                    color: Colors.black,
                    size: 110,
                  ),
                )
                .animate()
                .scale(duration: 1000.ms, curve: Curves.elasticOut)
                .shimmer(delay: 1500.ms, duration: 2.seconds, color: AppColors.primaryGold.withValues(alpha: 0.4)),
                
                const SizedBox(height: 60),
                
                const Text(
                  'FreeFlow',
                  style: TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -4,
                    color: Colors.black,
                  ),
                )
                .animate()
                .fadeIn(duration: 1000.ms, delay: 600.ms)
                .slideY(begin: 0.3, end: 0, curve: Curves.easeOutQuart),
                
                const SizedBox(height: 16),
                
                const Text(
                  'EXPERT NETWORK',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: Colors.black26,
                    letterSpacing: 10,
                  ),
                )
                .animate()
                .fadeIn(duration: 800.ms, delay: 1600.ms),
              ],
            ),
          ),

          // Barre de progression élégante
          Positioned(
            bottom: 80,
            left: 0, right: 0,
            child: Center(
              child: Container(
                width: 180,
                height: 3,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.02),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Stack(
                  children: [
                    Container()
                      .animate(onPlay: (c) => c.repeat())
                      .shimmer(duration: 2500.ms, color: AppColors.primaryGold.withValues(alpha: 0.6)),
                  ],
                ),
              ),
            ),
          ).animate().fadeIn(delay: 2000.ms),
        ],
      ),
    );
  }

  Widget _vortexRing(double size, double opacity, Duration duration, bool clockwise) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primaryGold.withValues(alpha: opacity),
          width: 1.5,
        ),
      ),
    ).animate(onPlay: (c) => c.repeat())
     .rotate(duration: duration, begin: clockwise ? 0 : 1, end: clockwise ? 1 : 0)
     .scale(begin: const Offset(0.85, 0.85), end: const Offset(1.15, 1.15), duration: Duration(milliseconds: duration.inMilliseconds ~/ 2), curve: Curves.easeInOutSine);
  }
}

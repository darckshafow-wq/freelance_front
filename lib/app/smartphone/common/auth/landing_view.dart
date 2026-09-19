import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:freelance_front/core/constants/app_colors.dart';

class LandingView extends StatelessWidget {
  const LandingView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;

    if (isDesktop) {
      return _buildDesktopLayout(context, size);
    }

    return _buildMobileLayout(context, size);
  }

  Widget _buildDesktopLayout(BuildContext context, Size size) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1F23),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: size.height * 0.85,
              width: double.infinity,
              decoration: const BoxDecoration(color: Color(0xFF1E1F23)),
              child: Stack(
                children: [
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    width: size.width * 0.45,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(100)),
                      child: Image.network(
                        'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?q=80&w=2070&auto=format&fit=crop',
                        fit: BoxFit.cover,
                        color: Colors.black.withValues(alpha: 0.4),
                        colorBlendMode: BlendMode.darken,
                      ),
                    ).animate().fadeIn(duration: 800.ms),
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context, true),
                      const SizedBox(height: 60),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 80),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildBadge(),
                                  const SizedBox(height: 24),
                                  const Text(
                                    'Hire Your\nBest Expert Talents',
                                    style: TextStyle(
                                      fontSize: 64,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      height: 1.1,
                                      letterSpacing: -1,
                                    ),
                                  ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.1),
                                  const SizedBox(height: 24),
                                  const Text(
                                    'FreeFlow is the premiere platform connecting global businesses\nwith world-class independent professionals.',
                                    style: TextStyle(fontSize: 16, color: Colors.white54, height: 1.6),
                                  ).animate().fadeIn(delay: 300.ms),
                                  const SizedBox(height: 48),
                                  _buildSearchBar(true),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  _buildServiceCard(title: 'Our Special\nService', color: const Color(0xFFEB8A7E), offset: const Offset(40, -40)),
                                  _buildServiceCard(
                                    title: 'Quality\nGuaranteed',
                                    subtitle: 'Certified experts and secure payments.',
                                    icon: Icons.verified_user_rounded,
                                    color: const Color(0xFF2C2D32),
                                    offset: const Offset(0, 100),
                                  ),
                                  _buildServiceCard(
                                    title: 'Fast\nDelivery',
                                    subtitle: 'Milestone tracking and on-time results.',
                                    icon: Icons.rocket_launch_rounded,
                                    color: const Color(0xFF2C2D32),
                                    offset: const Offset(120, 240),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, Size size) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Yellow Shapes
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 180,
              height: 180,
              decoration: const BoxDecoration(
                color: AppColors.primaryGold,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(100)),
              ),
            ),
          ).animate().slideX(begin: 1.0, duration: 600.ms, curve: Curves.easeOutQuart),

          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 1),
                // Logo Section (Center)
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)],
                      ),
                      child: const Icon(Icons.bolt_rounded, color: Colors.black, size: 60),
                    ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
                    const SizedBox(height: 24),
                    const Text(
                      'FreeFlow',
                      style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, letterSpacing: -1.5),
                    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
                    const Text(
                      'PREMIUM EXPERTS',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.black26, letterSpacing: 4),
                    ).animate().fadeIn(delay: 500.ms),
                  ],
                ),
                const Spacer(flex: 2),
                
                // Welcome Panel (Slides Up)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(40, 48, 40, 48),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryGold,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(50)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Welcome',
                        style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: Colors.black),
                      ).animate().fadeIn(delay: 700.ms),
                      const SizedBox(height: 12),
                      const Text(
                        'Join our network of elite independent professionals or hire the best talents globally.',
                        style: TextStyle(fontSize: 16, color: Colors.black54, height: 1.5, fontWeight: FontWeight.w600),
                      ).animate().fadeIn(delay: 800.ms),
                      const SizedBox(height: 48),
                      Row(
                        children: [
                          Expanded(
                            child: _mobileBtn(context, 'Sign In', Colors.black, Colors.white, () => context.push('/login')),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _mobileBtn(context, 'Sign Up', Colors.white, Colors.black, () => context.push('/register')),
                          ),
                        ],
                      ).animate().fadeIn(delay: 1000.ms).slideY(begin: 0.2),
                    ],
                  ),
                ).animate().slideY(begin: 1.0, duration: 800.ms, curve: Curves.easeOutQuart),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _mobileBtn(BuildContext context, String label, Color bg, Color text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 62,
        decoration: BoxDecoration(
          color: bg, 
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            if (bg == Colors.white) BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))
          ]
        ),
        alignment: Alignment.center,
        child: Text(label, style: TextStyle(color: text, fontWeight: FontWeight.w900, fontSize: 16)),
      ),
    );
  }

  // --- DESKTOP COMPONENTS ---
  Widget _buildHeader(BuildContext context, bool isDesktop) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 30),
      child: Row(
        children: [
          const Text('FREEFLOW', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1)),
          const Spacer(),
          TextButton(
            onPressed: () => context.push('/login'),
            child: const Text('Log In', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 15)),
          ),
          const SizedBox(width: 24),
          ElevatedButton(
            onPressed: () => context.push('/register'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: const Text('Sign Up', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFF4C4CFF), borderRadius: BorderRadius.circular(16)),
      child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 28),
    ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack);
  }

  Widget _buildSearchBar(bool isDesktop) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 15),
          const Icon(Icons.search_rounded, color: Colors.black45, size: 20),
          const SizedBox(width: 10),
          const Text('What are you looking for?', style: TextStyle(color: Colors.black26, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(width: 15),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4C4CFF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Search', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2);
  }

  Widget _buildServiceCard({required String title, String? subtitle, IconData? icon, required Color color, required Offset offset}) {
    return Transform.translate(
      offset: offset,
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 40, offset: const Offset(0, 15))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: Icon(icon, color: AppColors.primaryGold, size: 20),
              ),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, height: 1.2)),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ],
        ),
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1);
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 80),
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('FREEFLOW', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF1E1F23))),
                const SizedBox(height: 16),
                const Text('Empowering the future of work through transparency and excellence.', style: TextStyle(color: Colors.black54, fontSize: 14, height: 1.5)),
                const SizedBox(height: 24),
                Row(
                  children: [
                    _socialIcon(Icons.facebook),
                    const SizedBox(width: 12),
                    _socialIcon(Icons.camera_alt_outlined),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),
          _footerCol('Contact Us', ['+1 (800) FLOW-FREE', 'support@freeflow.com']),
          const SizedBox(width: 80),
          _footerCol('Resources', ['Missions Board', 'Expert Directory']),
        ],
      ),
    );
  }

  Widget _footerCol(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)),
        const SizedBox(height: 24),
        ...items.map((e) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(e, style: const TextStyle(color: Colors.black54, fontSize: 14)))),
      ],
    );
  }

  Widget _socialIcon(IconData i) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.05), shape: BoxShape.circle),
      child: Icon(i, size: 18, color: Colors.black54),
    );
  }
}

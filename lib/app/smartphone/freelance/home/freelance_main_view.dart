import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:freelance_front/core/routes/route_names.dart';
import 'package:freelance_front/core/widgets/floating_expandable_nav.dart';
import 'package:freelance_front/core/constants/app_colors.dart';

class FreelanceMainView extends StatefulWidget {
  final Widget child;

  const FreelanceMainView({super.key, required this.child});

  @override
  State<FreelanceMainView> createState() => _FreelanceMainViewState();
}

class _FreelanceMainViewState extends State<FreelanceMainView> {
  @override
  Widget build(BuildContext context) {
    final int currentIndex = _calculateSelectedIndex(context);

    return Scaffold(
      backgroundColor: AppColors.softWhite,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Positioned.fill(
            child: SafeArea(
              bottom: false,
              child: widget.child,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 16,
            child: SafeArea(
              top: false,
              child: Center(
                child: FloatingExpandableNav(
                  currentIndex: currentIndex,
                  onItemSelected: (index) => _onItemTapped(index, context),
                  onAddTap: () {
                    context.pushNamed('freelanceNotifications');
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith(RouteNames.freelanceDashboard)) return 0;
    if (location.startsWith(RouteNames.freelanceProposals)) return 2;
    if (location.startsWith(RouteNames.freelanceChat)) return 5;
    if (location.startsWith(RouteNames.freelanceProfile)) return 3;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go(RouteNames.freelanceDashboard);
        break;
      case 2:
        context.go(RouteNames.freelanceProposals);
        break;
      case 5:
        context.go(RouteNames.freelanceChat);
        break;
      case 3:
        context.go(RouteNames.freelanceProfile);
        break;
    }
  }
}

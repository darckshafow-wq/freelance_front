import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:freelance_front/core/routes/route_names.dart';
import 'package:freelance_front/core/widgets/floating_expandable_nav.dart';

class ClientMainView extends StatefulWidget {
  final Widget child;

  const ClientMainView({super.key, required this.child});

  @override
  State<ClientMainView> createState() => _ClientMainViewState();
}

class _ClientMainViewState extends State<ClientMainView> {
  @override
  Widget build(BuildContext context) {
    final int currentIndex = _calculateSelectedIndex(context);

    return Scaffold(
      resizeToAvoidBottomInset: false, // Évite le chevauchement si le clavier s'ouvre
      body: Stack(
        children: [
          // Le contenu principal de la vue
          Positioned.fill(
            child: widget.child,
          ),
          
          // La barre de navigation flottante fixée en bas
          Positioned(
            left: 0,
            right: 0,
            bottom: 16, // Distance du bas pour l'effet flottant
            child: SafeArea(
              top: false,
              child: Center(
                child: FloatingExpandableNav(
                  currentIndex: currentIndex,
                  onItemSelected: (index) => _onItemTapped(index, context),
                  onAddTap: () => context.pushNamed(RouteNames.clientCreateProject),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith(RouteNames.clientDashboard)) return 0;
    if (location.startsWith(RouteNames.clientFreelanceSearch)) return 1;
    if (location.startsWith(RouteNames.clientProjects)) return 2;
    if (location.startsWith(RouteNames.clientProfile)) return 3;
    if (location.startsWith(RouteNames.clientProposals)) return 4;
    if (location.startsWith(RouteNames.clientChat)) return 5;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.goNamed(RouteNames.clientDashboard);
        break;
      case 1:
        context.goNamed(RouteNames.clientFreelanceSearch);
        break;
      case 2:
        context.goNamed(RouteNames.clientProjects);
        break;
      case 3:
        context.goNamed(RouteNames.clientProfile);
        break;
      case 4:
        context.goNamed(RouteNames.clientProposals);
        break;
      case 5:
        context.goNamed(RouteNames.clientChat);
        break;
    }
  }
}
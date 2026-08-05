import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freelance_front/models/auth/user_model.dart';
import 'package:freelance_front/views/smartphone/onbor/landing_transition_page.dart';

void main() {
  group('LandingTransitionPage', () {
    test('resolveRedirectRoute returns the client workspace for clients', () {
      expect(resolveRedirectRoute(UserRole.client), '/client-home');
    });

    test(
      'resolveRedirectRoute returns the freelancer workspace for freelancers',
      () {
        expect(resolveRedirectRoute(UserRole.freelancer), '/freelance-home');
      },
    );

    test('resolveRedirectRoute returns the admin workspace for admins', () {
      expect(resolveRedirectRoute(UserRole.admin), '/admin');
    });

    testWidgets('renders the loading view with the app logo', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LandingTransitionPage(
            onRestoreSession: () async {},
            onNavigateToRoute: (_) {},
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(
        find.text('Chargement de votre espace de travail...'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.bolt_rounded), findsOneWidget);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:freelance_front/main.dart';

void main() {
  testWidgets('app boots without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}

// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_devsecops_template/main.dart';

void main() {
  testWidgets('App loads and displays correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our app title appears
    expect(find.text('Secure Flutter ToDo'), findsOneWidget);

    // Verify that the text field exists
    expect(find.byType(TextField), findsOneWidget);

    // Verify that the Add button exists
    expect(find.text('Add'), findsOneWidget);
  });

  testWidgets('Add item functionality works', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Enter text in the text field
    await tester.enterText(find.byType(TextField), 'Test Task');

    // Tap the Add button
    await tester.tap(find.text('Add'));
    await tester.pump();

    // Verify that the task was added
    expect(find.text('Test Task'), findsOneWidget);
  });
}

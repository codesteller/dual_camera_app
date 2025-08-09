// This is a basic Flutter widget test for the Dual Camera App.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dual_camera_app/main.dart';

void main() {
  testWidgets('Dual Camera App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const DualCameraApp());

    // Verify that the app starts and shows the home screen
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Dual Camera App'), findsWidgets);
    expect(find.text('Open Basic Camera View'), findsOneWidget);
  });

  testWidgets('Navigation to camera screen test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const DualCameraApp());

    // Find and tap the camera button
    final cameraButton = find.text('Open Basic Camera View');
    expect(cameraButton, findsOneWidget);

    await tester.tap(cameraButton);
    await tester.pumpAndSettle();

    // Verify navigation occurred by checking for camera screen content
    // Since we can't test actual camera functionality in widget tests,
    // we just verify the navigation completed
    expect(find.byType(DualCameraScreen), findsOneWidget);
  });
}

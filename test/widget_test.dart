// This is a basic Flutter widget test for FusionLens.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_lens/main.dart';

void main() {
  testWidgets('FusionLens smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FusionLensApp());

    // Verify that the app starts and shows the home screen
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('FusionLens'), findsWidgets);
    expect(find.text('Advanced Camera Experience'), findsOneWidget);
  });

  testWidgets('Navigation to camera screen test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FusionLensApp());

    // Find and tap the camera button
    final cameraButton = find.text('Dual Camera View');
    expect(cameraButton, findsOneWidget);

    await tester.tap(cameraButton);
    await tester.pumpAndSettle();

    // Verify navigation occurred by checking for camera screen content
    // Since we can't test actual camera functionality in widget tests,
    // we just verify the navigation completed
    expect(find.byType(DualCameraScreen), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cdegad_kp/main.dart';
import 'package:cdegad_kp/screens/home_screen.dart';
import 'package:cdegad_kp/screens/forms/cd_forms/cd.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget app() => const ProviderScope(child: MyApp());

  testWidgets('Splash screen shows branding then navigates to login', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(app());
    await tester.pump();

    expect(find.text('CDEGAD DIRECTORATE'), findsOneWidget);
    expect(find.text('Protecting Forests, Preserving Future'), findsWidgets);

    // Splash auto-navigates after 3s; login page fades in over 600ms and
    // runs an 800ms entrance animation.
    await tester.pump(const Duration(seconds: 4));
    await tester.pump(const Duration(milliseconds: 800));

    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Sign in to continue'), findsOneWidget);
  });

  testWidgets('Login validates the form and navigates to home on success', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(app());
    await tester.pump(const Duration(seconds: 4));
    await tester.pump(const Duration(milliseconds: 800));

    expect(find.text('Welcome Back'), findsOneWidget);

    // Empty submit shows validation errors.
    final loginButton = find.text('Login');
    await tester.ensureVisible(loginButton);
    await tester.tap(loginButton);
    await tester.pump();

    expect(find.text('Email required'), findsOneWidget);
    expect(find.text('Min 6 chars'), findsOneWidget);

    // Fill valid credentials and submit.
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'admin@forest.gov.pk',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.ensureVisible(loginButton);
    await tester.tap(loginButton);
    await tester.pump();

    // Simulated network delay shows a spinner.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(const Duration(seconds: 1)); // login delay completes
    await tester.pump(const Duration(milliseconds: 600)); // route transition
    await tester.pump(const Duration(seconds: 1)); // home load sequence
    await tester.pump(const Duration(seconds: 1)); // staggered card animations

    expect(find.text('Community Development'), findsWidgets);
    expect(find.text('Extension'), findsWidgets);
    expect(find.text('GAD'), findsWidgets);
  });

  testWidgets('Home feature grid navigates to the CD page', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        routes: {'/cd': (context) => const CDPage()},
        home: const HomeScreen(),
      ),
    );

    await tester.pump(const Duration(seconds: 1)); // initial load
    await tester.pump(const Duration(seconds: 1)); // staggered cards

    expect(find.text('Community Development'), findsWidgets);

    final cdCard = find.text('CD');
    await tester.ensureVisible(cdCard);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(cdCard);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400)); // route transition

    expect(
      find.text(
        'Select an option to manage and track community development initiatives',
      ),
      findsOneWidget,
    );
  });
}

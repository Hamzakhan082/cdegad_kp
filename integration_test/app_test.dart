import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cdegad_kp/main.dart' as app;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  // Without this, tester.enterText silently no-ops in profile/release builds
  // (flutter/flutter#87990).
  binding.testTextInput.register();
  const testFilter = String.fromEnvironment('TEST_NAME');

  void it(String name, WidgetTesterCallback body) {
    if (testFilter.isNotEmpty && !name.contains(testFilter)) return;
    testWidgets(name, body);
  }

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> pumpRoute(WidgetTester tester, [Duration d = const Duration(milliseconds: 900)]) async {
    await tester.pump(d);
  }

  // Some screens use zero-height AppBars whose implicit BackButton is not
  // hittable; simulate the system back button instead of tapping icons.
  Future<void> goBack(WidgetTester tester) async {
    await tester.binding.handlePopRoute();
    await pumpRoute(tester);
  }

  // Pumps until the given text is on stage (up to ~4.5s), tolerating async
  // API fetches that complete between frames.
  Future<void> waitForText(WidgetTester tester, String text) async {
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text(text).evaluate().isNotEmpty) return;
    }
  }

  // Taps a card in a lazy grid, scrolling it fully into view first. A bare
  // ensureVisible is not enough when the card's center stays below the fold,
  // and the grid retains its scroll position across visits, so search both
  // directions.
  Future<void> tapGridCard(WidgetTester tester, String label) async {
    final scrollable = find.byType(Scrollable).last;
    var card = find.text(label);
    if (card.evaluate().isEmpty) {
      try {
        await tester.scrollUntilVisible(card, 200, scrollable: scrollable, maxScrolls: 20);
      } catch (_) {}
      card = find.text(label);
    }
    if (card.evaluate().isEmpty) {
      try {
        await tester.scrollUntilVisible(card, -200, scrollable: scrollable, maxScrolls: 20);
      } catch (_) {}
      card = find.text(label);
    }
    if (card.evaluate().isEmpty) {
      fail('Could not find "$label" in the grid');
    }
    await tester.ensureVisible(card);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(card);
    await pumpRoute(tester);
  }

  Future<void> gotoLogin(WidgetTester tester) async {
    await tester.pumpWidget(const app.MyApp());
    await tester.pump(const Duration(seconds: 4)); // splash delay
    await tester.pump(const Duration(milliseconds: 800)); // splash -> login transition
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Welcome Back'), findsOneWidget);
  }

  Future<void> loginAndGoHome(WidgetTester tester) async {
    await gotoLogin(tester);
    await tester.enterText(find.byType(TextFormField).at(0), 'admin@forest.gov.pk');
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    final loginBtn = find.text('Login');
    await tester.ensureVisible(loginBtn);
    await tester.tap(loginBtn);
    await tester.pump(const Duration(seconds: 2)); // simulated login delay + navigation
    await tester.pump(const Duration(milliseconds: 800)); // route transition
    await tester.pump(const Duration(seconds: 2)); // home loading sequence
    await tester.pump(const Duration(seconds: 1)); // staggered card animations
    expect(find.text('Community Development'), findsWidgets);
  }

  it('app boots: splash shows branding then auto-navigates to login',
      (WidgetTester tester) async {
    await gotoLogin(tester);
    expect(find.text('Sign in to continue'), findsOneWidget);
  });

  it('login validates the form and navigates to home on success',
      (WidgetTester tester) async {
    await gotoLogin(tester);

    // Empty submit -> validation errors
    final loginBtn = find.text('Login');
    await tester.ensureVisible(loginBtn);
    await tester.tap(loginBtn);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Email required'), findsOneWidget);
    expect(find.text('Min 6 chars'), findsOneWidget);

    // Remember-me + valid credentials -> home
    await tester.enterText(find.byType(TextFormField).at(0), 'admin@forest.gov.pk');
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.tap(find.text('Remember me'));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.ensureVisible(loginBtn);
    await tester.tap(loginBtn);
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Community Development'), findsWidgets);
    expect(find.text('GAD'), findsWidgets);
  });

  it('forgot password dialog opens with offline message',
      (WidgetTester tester) async {
    await gotoLogin(tester);
    await tester.ensureVisible(find.text('Forgot Password?'));
    await tester.tap(find.text('Forgot Password?'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Forgot Password'), findsOneWidget);
    expect(find.textContaining('system administrator'), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Forgot Password'), findsNothing);
  });

  it('home feature grid navigates through CD module to VDC and JFMC forms and records',
      (WidgetTester tester) async {
    await loginAndGoHome(tester);

    // Open CD page
    final cdCard = find.text('CD');
    await tester.ensureVisible(cdCard);
    await tester.tap(cdCard);
    await pumpRoute(tester);
    expect(find.text('Select an option to manage and track community development initiatives'),
        findsOneWidget);

    // VDC -> Enter New Data -> form
    await tester.ensureVisible(find.text('VDC'));
    await tester.tap(find.text('VDC'));
    await pumpRoute(tester);
    expect(find.text('Choose an option'), findsWidgets);
    await tester.ensureVisible(find.text('Enter New Data'));
    await tester.tap(find.text('Enter New Data'));
    await pumpRoute(tester);
    expect(find.text('VDC Form'), findsWidgets);
    // Submit triggers validation or success, but must not crash.
    await tester.ensureVisible(find.text('Submit'));
    await tester.tap(find.text('Submit'));
    await tester.pump(const Duration(seconds: 3));
    await goBack(tester);
    await pumpRoute(tester);

    // VDC -> View Records
    await tester.ensureVisible(find.text('View Records'));
    await tester.tap(find.text('View Records'));
    await pumpRoute(tester);
    expect(find.text('VDC Records'), findsWidgets);
    await goBack(tester);
    await pumpRoute(tester);
    await goBack(tester); // back to CD page
    await pumpRoute(tester);

    // JFMC -> Enter New Data -> form
    await tester.ensureVisible(find.text('JFMC'));
    await tester.tap(find.text('JFMC'));
    await pumpRoute(tester);
    await tester.ensureVisible(find.text('Enter New Data'));
    await tester.tap(find.text('Enter New Data'));
    await pumpRoute(tester);
    expect(find.text('JFMC Form'), findsWidgets);
    await goBack(tester);
    await pumpRoute(tester);
    await goBack(tester); // back to CD page
    await pumpRoute(tester);
    await goBack(tester); // back to home
    await pumpRoute(tester);
    expect(find.text('Community Development'), findsWidgets);
  });

  it('extension module: mass planting and awareness raising screens render',
      (WidgetTester tester) async {
    await loginAndGoHome(tester);

    await tester.ensureVisible(find.text('Extension'));
    await tester.tap(find.text('Extension'));
    await pumpRoute(tester);
    expect(find.text('Extension Services'), findsOneWidget);

    // Mass Planting Event
    await tester.ensureVisible(find.text('Mass Planting Event'));
    await tester.tap(find.text('Mass Planting Event'));
    await pumpRoute(tester);
    expect(find.text('Mass Planting Event'), findsWidgets);
    await goBack(tester);
    await pumpRoute(tester);

    // Awareness Raising Sessions -> Enter New Data
    await tester.ensureVisible(find.text('Awareness Raising Sessions'));
    await tester.tap(find.text('Awareness Raising Sessions'));
    await pumpRoute(tester);
    expect(find.text('Choose an option'), findsWidgets);
    await tester.ensureVisible(find.text('Enter New Data'));
    await tester.tap(find.text('Enter New Data'));
    await pumpRoute(tester);
    expect(find.text('Awareness Raising Sessions'), findsWidgets);
    await tester.ensureVisible(find.text('Submit'));
    await tester.tap(find.text('Submit'));
    await tester.pump(const Duration(seconds: 3));
    await goBack(tester);
    await pumpRoute(tester);
    await goBack(tester);
    await pumpRoute(tester);
    await goBack(tester); // back to home
    await pumpRoute(tester);
    expect(find.text('Community Development'), findsWidgets);
  });

  it('gad module: every option opens its form page',
      (WidgetTester tester) async {
    await loginAndGoHome(tester);

    await tester.ensureVisible(find.text('GAD'));
    await tester.tap(find.text('GAD'));
    await pumpRoute(tester);
    expect(find.text('Women Organization'), findsOneWidget);

    // Farm / Agro Forestry -> form
    await tapGridCard(tester, 'Farm / Agro Forestry');
    await tester.ensureVisible(find.text('Enter New Data'));
    await tester.tap(find.text('Enter New Data'));
    await pumpRoute(tester);
    expect(find.text('Submit Form'), findsWidgets);
    await goBack(tester);
    await pumpRoute(tester);
    await goBack(tester);
    await pumpRoute(tester);

    // Women Organization -> form
    await tapGridCard(tester, 'Women Organization');
    await tester.ensureVisible(find.text('Enter New Data'));
    await tester.tap(find.text('Enter New Data'));
    await pumpRoute(tester);
    expect(find.text('Submit Form'), findsWidgets);
    await goBack(tester);
    await pumpRoute(tester);
    await goBack(tester);
    await pumpRoute(tester);

    // Other Activity -> form
    await tapGridCard(tester, 'Other Activity');
    await tester.ensureVisible(find.text('Enter New Data'));
    await tester.tap(find.text('Enter New Data'));
    await pumpRoute(tester);
    expect(find.text('Submit Form'), findsWidgets);
    await goBack(tester);
    await pumpRoute(tester);
    await goBack(tester);
    await pumpRoute(tester);
    await goBack(tester); // back to home
    await pumpRoute(tester);
    expect(find.text('Community Development'), findsWidgets);
  });

  it('bottom nav opens Records, Alerts and Profile; downloads card opens downloads',
      (WidgetTester tester) async {
    await loginAndGoHome(tester);

    // Records
    await tester.ensureVisible(find.text('Records'));
    await tester.tap(find.text('Records'));
    await pumpRoute(tester);
    expect(find.text('All Records'), findsWidgets);
    await goBack(tester);
    await pumpRoute(tester);

    // Alerts
    await tester.ensureVisible(find.text('Alerts'));
    await tester.tap(find.text('Alerts'));
    await pumpRoute(tester);
    expect(find.text('Alerts & Notifications'), findsWidgets);
    await goBack(tester);
    await pumpRoute(tester);

    // Profile
    await tester.ensureVisible(find.text('Profile'));
    await tester.tap(find.text('Profile'));
    await pumpRoute(tester);
    expect(find.text('Profile'), findsWidgets);
    // Activity History dialog
    await tester.ensureVisible(find.text('Activity History'));
    await tester.tap(find.text('Activity History'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Activity History'), findsWidgets);
    await tester.tap(find.text('Close'));
    await tester.pump(const Duration(milliseconds: 300));
    await goBack(tester);
    await pumpRoute(tester);

    // Downloads card
    await tester.ensureVisible(find.text('Downloads'));
    await tester.tap(find.text('Downloads'));
    await pumpRoute(tester);
    expect(find.text('Downloads - Department Records'), findsOneWidget);
    await goBack(tester);
    await pumpRoute(tester);
    expect(find.text('Community Development'), findsWidgets);
  });

  it('drawer navigation and logout work',
      (WidgetTester tester) async {
    await loginAndGoHome(tester);

    Future<void> openDrawer() async {
      final menuIcon = find.byIcon(Icons.menu);
      if (menuIcon.evaluate().isNotEmpty) {
        await tester.tap(menuIcon);
      } else {
        await tester.dragFrom(const Offset(10, 400), const Offset(350, 0));
      }
      await tester.pump(const Duration(milliseconds: 800));
    }

    // Open drawer by edge swipe (home screen has no app-bar menu button)
    await openDrawer();
    expect(find.text('CD Forms'), findsWidgets);

    // Settings -> coming soon snackbar
    await tester.tap(find.text('Settings'));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Settings Page - Coming Soon!'), findsWidgets);
    await tester.pump(const Duration(seconds: 4)); // let snackbar expire

    // Logout
    await openDrawer();
    await tester.tap(find.text('Logout'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(milliseconds: 800));
    expect(find.text('Welcome Back'), findsOneWidget);
  });

  // Opens View Records for a GAD activity and returns to home.
  // Verifies the backend data text (if provided) while still on the records
  // page, before navigating back.
  Future<void> openRecords(WidgetTester tester, String activity, String recordsTitle,
      {String? expectedData}) async {
    await tester.ensureVisible(find.text('GAD'));
    await tester.tap(find.text('GAD'));
    await pumpRoute(tester);
    expect(find.text('Women Organization'), findsOneWidget);
    final card = find.text(activity);
    if (card.evaluate().isEmpty) {
      // Lazy grid: activity card may be below the fold.
      await tester.scrollUntilVisible(card, 250,
          scrollable: find.byType(Scrollable).last);
      await tester.pump(const Duration(milliseconds: 300));
    }
    await tester.ensureVisible(card);
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(card);
    await pumpRoute(tester);
    expect(find.text('Enter New Data'), findsWidgets);
    final vr = find.text('View Records');
    await tester.ensureVisible(vr);
    await tester.tap(vr);
    await pumpRoute(tester);
    await tester.pump(const Duration(seconds: 3)); // allow API fetch
    expect(find.text(recordsTitle), findsWidgets);
    if (expectedData != null) {
      await waitForText(tester, expectedData);
      expect(find.text(expectedData), findsWidgets);
    }
    await goBack(tester); // back to OptionPage
    expect(find.text('Enter New Data'), findsWidgets);
    await goBack(tester); // back to GAD grid
    expect(find.text('Gender & Development'), findsWidgets); // grid header always built
    await goBack(tester); // back to home
    await pumpRoute(tester);
    expect(find.text('Community Development'), findsWidgets);
  }

  it('Farm / Agro Forestry records display from backend',
      (WidgetTester tester) async {
    await loginAndGoHome(tester);
    await openRecords(tester, 'Farm / Agro Forestry', 'Farm / Agro Forestry Records',
        expectedData: 'Sheesham'); // seeded major_species
  });

  it('Women Nursery records display from backend',
      (WidgetTester tester) async {
    await loginAndGoHome(tester);
    await openRecords(tester, 'Women Nursery', 'Women Nursery Records',
        expectedData: 'Fatima Bibi'); // seeded nursery owner
  });

  it('Other Activity records display from backend',
      (WidgetTester tester) async {
    await loginAndGoHome(tester);
    await openRecords(tester, 'Other Activity', 'Other Activity Records',
        expectedData: 'Kitchen Garden Training'); // seeded activity title
  });

  it('awareness form submits to backend',
      (WidgetTester tester) async {
    await loginAndGoHome(tester);

    // Navigate: Extension -> Awareness Raising Sessions -> Enter New Data
    await tester.ensureVisible(find.text('Extension'));
    await tester.tap(find.text('Extension'));
    await pumpRoute(tester);
    await tester.ensureVisible(find.text('Awareness Raising Sessions'));
    await tester.tap(find.text('Awareness Raising Sessions'));
    await pumpRoute(tester);
    await tester.ensureVisible(find.text('Enter New Data'));
    await tester.tap(find.text('Enter New Data'));
    await pumpRoute(tester);

    // Fill all required fields
    Future<void> fill(String label, String value) async {
      final f = find.widgetWithText(TextFormField, label);
      await tester.ensureVisible(f);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.enterText(f, value);
      await tester.pump(const Duration(milliseconds: 100));
    }

    await fill('Employee Name', 'Integration Tester');
    await fill('Name of Forest Circle', 'Circle A');
    await fill('Name of Division', 'Division B');
    await fill('Name of Sub-Division / Range', 'Range C');
    await fill('Name of Project', 'Project D');
    await fill('Type of Event', 'Automated Integration Event');
    await fill('Name of Institution / Organization', 'Forest Institute');
    await fill('Venue', 'Peshawar');
    await fill('Chief Guest', 'Director');
    await fill('Description', 'Created by integration test');

    // Select the region dropdown
    final dd = find.byType(DropdownButtonFormField<String>);
    await tester.ensureVisible(dd);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(dd);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('Region I').last);
    await tester.pump(const Duration(milliseconds: 400));

    // Submit
    final submitBtn = find.text('Submit');
    await tester.ensureVisible(submitBtn);
    await tester.tap(submitBtn);
    await tester.pump(const Duration(seconds: 4)); // API round-trip + snackbar
    expect(find.textContaining('saved successfully'), findsWidgets);
  });

  it('awareness records display and delete from backend',
      (WidgetTester tester) async {
    await loginAndGoHome(tester);

    // Navigate: Extension -> Awareness Raising Sessions -> View Records
    await tester.ensureVisible(find.text('Extension'));
    await tester.tap(find.text('Extension'));
    await pumpRoute(tester);
    await tester.ensureVisible(find.text('Awareness Raising Sessions'));
    await tester.tap(find.text('Awareness Raising Sessions'));
    await pumpRoute(tester);
    await tester.ensureVisible(find.text('View Records'));
    await tester.tap(find.text('View Records'));
    await pumpRoute(tester);
    await tester.pump(const Duration(seconds: 3)); // allow API fetch
    expect(find.text('Awareness Raising Sessions Records'), findsWidgets);
    expect(find.text('Automated Integration Event'), findsWidgets);

    // Delete every record created by the integration test (loop in case a
    // previous crashed run left leftovers behind).
    while (find.text('Automated Integration Event').evaluate().isNotEmpty) {
      final del = find.byIcon(Icons.delete).first;
      if (del.evaluate().isNotEmpty) {
        final scrollable = find.byType(Scrollable).last;
        try {
          await tester.scrollUntilVisible(del, 100, scrollable: scrollable, maxScrolls: 20);
        } catch (_) {}
        try {
          await tester.scrollUntilVisible(del, -100, scrollable: scrollable, maxScrolls: 20);
        } catch (_) {}
      }
      await tester.pump(const Duration(milliseconds: 200));
      final rc = tester.getRect(del);
      await tester.tapAt(rc.center);
      await tester.pump(const Duration(milliseconds: 400));
      final confirm = find.widgetWithText(ElevatedButton, 'Delete');
      if (confirm.evaluate().isNotEmpty) {
        await tester.tap(confirm);
        await tester.pump(const Duration(seconds: 3)); // API delete + refetch
      } else {
        fail('Delete confirmation dialog did not open');
      }
    }
    expect(find.text('Automated Integration Event'), findsNothing);

    await goBack(tester);
    await pumpRoute(tester);
    await goBack(tester);
    await pumpRoute(tester);
    await goBack(tester); // back to home
    await pumpRoute(tester);
    expect(find.text('Community Development'), findsWidgets);
  });
}

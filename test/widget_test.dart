import 'package:fix_rwanda/app.dart';
import 'package:fix_rwanda/models/booking.dart';
import 'package:fix_rwanda/models/professional.dart';
import 'package:fix_rwanda/screens/account_screen.dart';
import 'package:fix_rwanda/screens/login_screen.dart';
import 'package:fix_rwanda/screens/tracking_screen.dart';
import 'package:fix_rwanda/state/app_controller.dart';
import 'package:fix_rwanda/theme/app_theme.dart';
import 'package:fix_rwanda/widgets/phone_frame.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('splash shows FixRwanda branding', (tester) async {
    await tester.pumpWidget(FixRwandaApp(controller: AppController()));
    expect(find.text('FixRwanda'), findsOneWidget);
    expect(
      find.text('Verified professionals, booked in minutes.'),
      findsOneWidget,
    );
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('account screen shows menu tiles and sign out', (tester) async {
    final controller = AppController();
    controller.customer = const Customer(
      id: 'c1',
      name: 'Ada',
      identifier: 'ada@fixrwanda.rw',
    );
    await tester.pumpWidget(
      FixRwandaScope(
        controller: controller,
        child: const MaterialApp(home: Scaffold(body: ProfileScreen())),
      ),
    );
    expect(find.text('Ada'), findsOneWidget);
    expect(find.text('Edit Profile'), findsOneWidget);
    expect(find.text('Payment Methods'), findsOneWidget);
    expect(find.text('Booking History'), findsOneWidget);
    expect(find.text('Help & Support'), findsOneWidget);
    expect(find.text('Sign out'), findsOneWidget);
    expect(find.textContaining('Debug Mode'), findsNothing);
    expect(find.textContaining('Connected to API'), findsNothing);
  });

  testWidgets('hides flutter debug banner and uses a light web canvas', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    await tester.pumpWidget(FixRwandaApp(controller: AppController()));
    expect(find.byType(Banner), findsNothing);
    expect(find.textContaining('Debug Mode'), findsNothing);
    expect(find.byType(PhoneFrame), findsOneWidget);
    final canvas = tester.widget<ColoredBox>(find.byType(ColoredBox).first);
    expect(canvas.color, AppColors.canvas);
    await tester.pumpWidget(const SizedBox.shrink());
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('auth screen toggles between sign in and sign up', (tester) async {
    await tester.pumpWidget(
      FixRwandaScope(
        controller: AppController(),
        child: const MaterialApp(home: LoginScreen()),
      ),
    );
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Use demo account'), findsNothing);
    await tester.tap(find.text("Don't have an account? Sign Up"));
    await tester.pump();
    expect(find.text('Create Account'), findsOneWidget);
    expect(find.text('Sign Up'), findsOneWidget);
    expect(find.text('Full name'), findsOneWidget);
  });

  testWidgets('tracking screen shows provider overlay', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: InAppTrackingScreen(
          providerName: 'Jean Mugabo Electrical',
          status: BookingStatus.enRoute,
          jobLocation: 'Kigali, Nyarugenge',
          locateUser: false,
        ),
      ),
    );
    expect(find.textContaining('Tracking Jean Mugabo Electrical'), findsOneWidget);
    expect(find.text('Jean Mugabo Electrical'), findsWidgets);
    expect(find.text('On the way • Estimated arrival: 15 mins'), findsOneWidget);
    expect(find.text('Recenter Map'), findsOneWidget);
    expect(find.text('Use demo account'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('keeps a signed-in user after restoreSession', (tester) async {
    SharedPreferences.setMockInitialValues({
      'fixrwanda.session.customer':
          '{"id":"c1","name":"Ada","identifier":"ada@fixrwanda.rw","role":"customer","token":"tok"}',
      'fixrwanda.session.token': 'tok',
      'fixrwanda.session.last_identifier': 'ada@fixrwanda.rw',
    });
    final controller = AppController();
    await controller.restoreSession();
    expect(controller.isSignedIn, isTrue);
    expect(controller.customer?.name, 'Ada');
    expect(controller.rememberedIdentifier, 'ada@fixrwanda.rw');
    await controller.signOut();
    expect(controller.isSignedIn, isFalse);
    expect(controller.rememberedIdentifier, 'ada@fixrwanda.rw');
  });
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fixrwanda/app.dart';
import 'package:fixrwanda/data/local_marketplace_store.dart';
import 'package:fixrwanda/screens/home_shell.dart';
import 'package:fixrwanda/state/marketplace_controller.dart';
import 'package:fixrwanda/theme/app_theme.dart';
import 'package:fixrwanda/widgets/phone_frame.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('FixRwanda sign-in screen loads', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final store = LocalMarketplaceStore();
    await store.initialize();
    final controller = MarketplaceController(store);

    await tester.pumpWidget(FixRwandaRoot(controller: controller));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('FixRwanda'), findsWidgets);
    expect(find.textContaining('Kigali marketplace'), findsOneWidget);
  });

  testWidgets('desktop canvas wraps the app in a phone chassis', (tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    debugDefaultTargetPlatformOverride = TargetPlatform.windows;

    SharedPreferences.setMockInitialValues({});
    final store = LocalMarketplaceStore();
    await store.initialize();
    final controller = MarketplaceController(store);

    await tester.pumpWidget(FixRwandaRoot(controller: controller));
    await tester.pump();
    expect(find.byType(PhoneFrame), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('signed-in home shows the Kigali hero and categories', (tester) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues({});
    final store = LocalMarketplaceStore();
    await store.login(
      identifier: 'hannington@fixrwanda.rw',
      password: 'rwanda123',
    );
    final controller = MarketplaceController(store);
    await controller.boot();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: controller,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const HomeShell(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.textContaining('Muraho'), findsOneWidget);
    expect(find.textContaining('Find a professional'), findsOneWidget);
    expect(find.text('Plumbing'), findsWidgets);
    expect(find.text('Escrow, not cash'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    controller.dispose();
  });
}

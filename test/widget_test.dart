import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fixrwanda/app.dart';
import 'package:fixrwanda/data/local_marketplace_store.dart';
import 'package:fixrwanda/state/marketplace_controller.dart';

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
}

import 'package:flutter/material.dart';

import 'app.dart';
import 'data/local_marketplace_store.dart';
import 'state/marketplace_controller.dart';
import 'web_url_strategy_stub.dart'
    if (dart.library.html) 'web_url_strategy_web.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureUrlStrategy();
  final store = LocalMarketplaceStore();
  await store.initialize();
  final controller = MarketplaceController(store);
  runApp(FixRwandaRoot(controller: controller));
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'app.dart';
import 'data/local_marketplace_store.dart';
import 'state/marketplace_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    setUrlStrategy(HashUrlStrategy());
  }
  final store = LocalMarketplaceStore();
  await store.initialize();
  final controller = MarketplaceController(store);
  runApp(FixRwandaRoot(controller: controller));
}

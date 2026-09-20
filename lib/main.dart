import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'app.dart';
import 'state/app_controller.dart';
import 'utils/google_maps_setup.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    setUrlStrategy(HashUrlStrategy());
  }
  await configureGoogleMapsAndroid();
  runApp(FixRwandaApp(controller: AppController()));
}

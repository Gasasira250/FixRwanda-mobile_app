import 'package:flutter/material.dart';

import 'app.dart';
import 'state/app_controller.dart';
import 'utils/google_maps_setup.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureGoogleMapsAndroid();
  runApp(FixRwandaApp(controller: AppController()));
}

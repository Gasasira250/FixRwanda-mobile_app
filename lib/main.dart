import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'app.dart';
import 'state/app_controller.dart';
import 'theme/app_theme.dart';
import 'utils/google_maps_setup.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.primaryBlue,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  if (kIsWeb) {
    setUrlStrategy(HashUrlStrategy());
  }
  await configureGoogleMapsAndroid();
  runApp(FixRwandaApp(controller: AppController()));
}

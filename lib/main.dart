import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kathoram/firebase_options.dart';
import 'package:kathoram/services/firebase_fcm.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

import 'local_storage/shared_pref.dart';
import 'routes/route_pages.dart';
import 'routes/route_path.dart';
import 'services/zego_call_service.dart';
import 'utils/navigator_key_utils.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MySharedPref.init();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  await FirebaseAndNotification.initNotification();

  MySharedPref.init();

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.black,
    ),
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // CRITICAL: Must be called BEFORE runApp()
  await ZegoCallService.instance.initialSetUp(NavigatorKeyHelper.navigatorKey);

  runApp(const KathoramApp());
}

class KathoramApp extends StatelessWidget {
  const KathoramApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      navigatorKey: NavigatorKeyHelper.navigatorKey,
      title: 'Kathoram Agent App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        textTheme: GoogleFonts.montserratTextTheme(),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.transparent,
          iconTheme: IconThemeData(color: Colors.black),
        ),
      ),
      builder: (context, child) {
        return Stack(
          children: [
            child!,
            // Minimized call overlay — shows floating mini window
            // when user navigates away during an active call.
            ZegoUIKitPrebuiltCallMiniOverlayPage(
              contextQuery: () {
                return NavigatorKeyHelper.navigatorKey.currentState!.context;
              },
            ),
          ],
        );
      },
      initialRoute: RoutePath.initial,
      getPages: RoutePages.routes,
    );
  }
}

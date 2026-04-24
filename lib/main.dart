import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'local_storage/shared_pref.dart';
import 'routes/route_pages.dart';
import 'routes/route_path.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MySharedPref.init();
  runApp(const KathoramApp());
}

class KathoramApp extends StatelessWidget {
  const KathoramApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Kathoram',
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
      initialRoute: RoutePath.initial,
      getPages: RoutePages.routes,
    );
  }
}

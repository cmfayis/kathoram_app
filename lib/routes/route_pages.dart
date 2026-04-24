import 'package:get/get.dart';

import '../features/newfeature/auth/controller/auth_controller.dart';
import '../features/newfeature/screens/approval_screen.dart';
import '../features/newfeature/screens/create_account_screen.dart';
import '../features/newfeature/screens/login_screen.dart';
import '../features/newfeature/screens/main_layout.dart';
import '../features/newfeature/screens/splash_screen.dart';
import '../features/newfeature/screens/upload_profile_picture_screen.dart';
import 'route_path.dart';

class RoutePages {
  static const transition = Transition.fadeIn;

  static final routes = [
    GetPage(
      name: RoutePath.initial,
      page: () => const SplashScreen(),
      transition: transition,
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
      }),
    ),
    GetPage(
      name: RoutePath.splash,
      page: () => const SplashScreen(),
      transition: transition,
    ),
    GetPage(
      name: RoutePath.signIn,
      page: () => const LoginScreen(),
      transition: transition,
    ),
    GetPage(
      name: RoutePath.signUp,
      page: () => const CreateAccountScreen(),
      transition: transition,
    ),
    GetPage(
      name: RoutePath.uploadProfilePicture,
      page: () => const UploadProfilePictureScreen(),
      transition: transition,
    ),
    GetPage(
      name: RoutePath.approval,
      page: () => const ApprovalPendingScreen(),
      transition: transition,
    ),
    GetPage(
      name: RoutePath.bottomNav,
      page: () => const MainLayout(),
      transition: transition,
    ),
  ];
}

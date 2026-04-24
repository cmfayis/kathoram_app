import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class NavigatorKeyHelper {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static BuildContext get getCurrentContext {
    return navigatorKey.currentContext!;
  }

  static double get screenHeight {
    return Get.height;
  }

  static double get screenWidth {
    return Get.width;
  }

  static Size get screenSize {
    return MediaQuery.sizeOf(getCurrentContext);
  }

  static keyboardUnFocus() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  static autoScroll(GlobalKey key) {
    try {
      Scrollable.ensureVisible(key.currentContext!,
          duration: const Duration(milliseconds: 1000), curve: Curves.easeOut);
    } catch (e) {
      // TODO
    }
  }

}

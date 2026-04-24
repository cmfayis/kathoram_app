
import 'package:flutter/material.dart';

import '../../../utils/navigator_key_utils.dart';

class CustomDialogs {
  static showDialogs(
      {required Widget child,
      Color? backGroundColor,
      double borderRadius = 15}) {
    showGeneralDialog(
      context: NavigatorKeyHelper.getCurrentContext,
      barrierDismissible: true,
      barrierLabel: "",
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return Dialog(
          insetPadding: const EdgeInsets.only(left: 20,right: 20,top: 50),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius)),
          backgroundColor: backGroundColor ,
          child: ConstrainedBox(
            constraints:  BoxConstraints(maxWidth: 500,maxHeight: NavigatorKeyHelper.screenHeight*0.7),
            child: child,
          ),
        );
      },
    );
  }

  static showFullDialogs({required Widget child}) {
    showGeneralDialog(
      context: NavigatorKeyHelper.getCurrentContext,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 0),
          child: child,
        );
      },
    );
  }

  static showBottomSheet({required Widget child}) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: NavigatorKeyHelper.getCurrentContext,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(20), topLeft: Radius.circular(20)),
      ),
      constraints:
          BoxConstraints(maxHeight: NavigatorKeyHelper.screenHeight * 0.8),
      builder: (BuildContext context) {
        return child;
      },
    );
  }
}

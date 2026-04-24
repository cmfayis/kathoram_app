
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSize {
  final String title;
  final Widget? leading;
  final bool? isNameFontSize;
  final Color? backgroundColor;
  final bool centerTitle;
  final bool? leadingEnable;
  final Color? textColor;
  final bool? isShadowEnable;
  final bool? isBorderLineEnable;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final Widget? titleWidget;
  final double? leadingWidth;
  final double preSize;
  final double toolBarHeight;

  const CustomAppBar({
    super.key,
    this.title = "",
    this.leading,
    this.backgroundColor,
    this.centerTitle = false,
    this.textColor,
    this.actions,
    this.bottom,
    this.leadingEnable = true,
    this.isShadowEnable = true,
    this.isBorderLineEnable = true,
    this.isNameFontSize = false,
    this.titleWidget,
    this.leadingWidth,
    this.preSize = 50,
    this.toolBarHeight = 66,
  });

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size(double.infinity, preSize),
      child: SafeArea(
        child: AppBar(
          toolbarHeight: toolBarHeight,
          leading: leading,
          leadingWidth: leadingWidth ?? 40,
          automaticallyImplyLeading: true,
          surfaceTintColor: backgroundColor,
          title: titleWidget ??
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  title,
                  textAlign: TextAlign.start,
                ),
              ),
          elevation: 0,
          centerTitle: centerTitle,
          // iconTheme: IconThemeData(color: CustomColor.primaryColor),
          backgroundColor: backgroundColor ,
          actions: actions,
          bottom: bottom,
        ),
      ),
    );
  }

  @override
  Widget get child => throw UnimplementedError();

  @override
  Size get preferredSize => Size(double.infinity, preSize);
}

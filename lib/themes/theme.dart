import 'package:flutter/material.dart';

class CustomThemes {
 static ThemeData themeDataLight() {
    return ThemeData(
      inputDecorationTheme: textFieldInputDecoration,
      elevatedButtonTheme: elevatedButtonThemeData,
      splashFactory: NoSplash.splashFactory,
      // highlightColor: ThemeColors.transparent,

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: Colors.black.withOpacity(0),
      ),
      dividerTheme: const DividerThemeData(
        thickness: 1,
        color: Colors.grey,
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
      ),
      useMaterial3: false,
    );
  }

 static ThemeData themeDataDark() {
    return ThemeData(
      inputDecorationTheme: textFieldInputDecoration,
      elevatedButtonTheme: elevatedButtonThemeData,
      splashFactory: NoSplash.splashFactory,
      // highlightColor: ThemeColors.transparent,

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: Colors.black.withOpacity(0),
      ),
      dividerTheme: const DividerThemeData(
        thickness: 1,
        color: Colors.grey,
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
      ),
      useMaterial3: false,
    );
  }

 static ElevatedButtonThemeData get elevatedButtonThemeData {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(100))),
    );
  }

 static InputDecorationTheme get textFieldInputDecoration {
    return InputDecorationTheme(
      filled: true,
      isDense: true,
      contentPadding: const EdgeInsets.only(top: 15, bottom: 13, left: 16),
      border: InputBorder.none,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: BorderSide.none,
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: BorderSide.none,
      ),
      // errorStyle:
      // GetTextStyle.styleS14w400GreyC8.copyWith(color: ThemeColors.redFF44),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: BorderSide.none,
      ),
    );
  }
}

import 'package:get/get.dart';

class CustomNavigator {
  static void push(
    String routeName, {
    dynamic arguments,
    int? id,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
  }) {
    Get.toNamed(
      routeName,
      arguments: arguments,
      id: id,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
    );
  }

  static void pushReplacement(
    String routeName, {
    dynamic arguments,
    int? id,
  }) {
    Get.offNamed(
      routeName,
      arguments: arguments,
      id: id,
    );
  }

  static void popAndReplace(
    String routeName, {
    dynamic arguments,
    int? id,
    Map<String, String>? parameters,
  }) {
    Get.offAndToNamed(
      routeName,
      arguments: arguments,
      id: id,
      parameters: parameters,
    );
  }

  static void pushCompleteReplacement(
    String routeName, {
    dynamic arguments,
    int? id,
    Map<String, String>? parameters,
  }) {
    Get.offAllNamed(
      routeName,
      arguments: arguments,
      id: id,
      parameters: parameters,
    );
  }

  static void popToNamed(
    String routeName, {
    int? id,
  }) {
    Get.until(
      (s) => s.currentResult == routeName,
      id: id,
    );
  }

  static void pushNamedAndRemoveUntil(
    String routeName,
    String removeUntilScreen, {
    dynamic arguments,
    int? id,
    Map<String, String>? parameters,
  }) {
    Get.offNamedUntil(
      routeName,
      (route) => route.settings.name == removeUntilScreen,
      arguments: arguments,
      id: id,
      parameters: parameters,
    );
  }

  static void pop({
    int? id,
  }) {
    Get.back(id: id);
  }

  static void popTwice({
    int? id,
  }) {
    Get.back(id: id);
    Get.back(id: id);
  }
}

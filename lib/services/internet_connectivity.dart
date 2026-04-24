import 'package:connectivity_plus/connectivity_plus.dart';

class InternetConnectivity {
  static Future<String?> checkConnectivity() async {
    final List<ConnectivityResult> connectivityResult =
        await (Connectivity().checkConnectivity());

    if (connectivityResult.contains(ConnectivityResult.none)) {
      return "Please check your internet connection";
    }
    return null;
  }

  // Use this for streaming continuously
  static streamInternetConnection() {
    Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> result) {});
  }
}

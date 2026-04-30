import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirebaseAndNotification {
  static var messaging = FirebaseMessaging.instance;

  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static var androidChannel = const AndroidNotificationChannel(
    "high_importance_channel",
    "notification",
    showBadge: true,
    importance: Importance.max,
  );

  static var notificationDetails = const NotificationDetails(
    android: AndroidNotificationDetails('CHANNEL_ID 1', 'CHANNEL_NAME 1',
        channelDescription: "CHANNEL_DESCRIPTION 1",
        importance: Importance.max,
        priority: Priority.high,
        timeoutAfter: null,
        styleInformation: DefaultStyleInformation(true, true),
        icon: '@mipmap/ic_launcher'),
  );

  static Future<void> requestNotificationPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  static initNotification() async {
    requestNotificationPermission();
    initPushNotification();
    initLocalNotification();
  }

  static Future<void> initPushNotification() async {
    await messaging.setForegroundNotificationPresentationOptions(
        alert: true, badge: true, sound: true);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      // logger.i("--${message}");
      if (notification != null) {
        showMessageNotification(
            messageData: message.toMap(),
            messageBody: notification.body ?? "",
            messageTitle: notification.title ?? "");
      }
    });
  }

  static Future<void> firebaseListeting() async {}

  static Future<String?> getFcmToken() async {
    try {
      // if (Platform.isIOS) {
      //   return await messaging.getAPNSToken();
      // }
      var token = await messaging.getToken();
      return token;
    } catch (e) {
      log("$e");
      return null;
    }
  }

  static Future deleteFcmToken() async {
    await messaging.deleteToken();
  }

  static initLocalNotification() async {
    final AndroidInitializationSettings initializationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    final DarwinInitializationSettings initializationSettingsIOS =
        const DarwinInitializationSettings();
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveBackgroundNotificationResponse: onReceiveNotification,
      onDidReceiveNotificationResponse: onReceiveNotification,
    );
  }

  static Future<void> showMessageNotification({
    required Map messageData,
    String messageTitle = "",
    String messageBody = "",
  }) async {
    RemoteNotification notification =
        RemoteNotification(title: messageTitle, body: messageBody);

    await flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      notificationDetails,
      payload: jsonEncode(messageData),
    );
  }

  static void onReceiveNotification(NotificationResponse response) async {}
}

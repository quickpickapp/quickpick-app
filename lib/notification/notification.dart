import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:quickpick/config/firebase_options.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await _processFirebaseMessage(message);
}

Future<void> firebaseMessagingForegroundHandler(RemoteMessage message) async {
  await _processFirebaseMessage(message);
}

Future<void> _processFirebaseMessage(RemoteMessage message) async {
  if (message.data.isEmpty) {
    return;
  }
  String? title = message.data['title'];
  String? body = message.data['body'];
  String? partner = message.data['partner'];
  String? campaign = message.data['campaign'];
  await _showLocalNotification(title, body, partner, campaign);
}

Future<void> _showLocalNotification(
    String? title, String? body, String? partner, String? campaign) async {
  const storage = FlutterSecureStorage();
  if ((await storage.read(key: "notifications") ?? "") == "false") {
    return;
  }
  var androidDetails = AndroidNotificationDetails(
    "quickpick",
    "QuickPick",
    importance: Importance.max,
    priority: Priority.high,
    ticker: 'ticker',
    color: const Color.fromARGB(255, 255, 255, 255),
  );
  var iosDetails = DarwinNotificationDetails();
  var notificationDetails =
      NotificationDetails(android: androidDetails, iOS: iosDetails);
  final payload = json.encode({
    'partner': partner,
    'campaign': campaign,
  });
  await flutterLocalNotificationsPlugin.show(
    0,
    title,
    body,
    notificationDetails,
    payload: payload,
  );
}

class QuickPickNotification {
  final GlobalKey<NavigatorState> navigatorKey;

  QuickPickNotification({required this.navigatorKey});

  Future<void> setup() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await initializeLocalNotifications();
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging.requestPermission();
    if (!kIsWeb && Platform.isIOS) {
      await messaging.getAPNSToken();
    }
    messaging.subscribeToTopic("quickpick");
    FirebaseMessaging.onMessage.listen(firebaseMessagingForegroundHandler);
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    final details =
        await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp ?? false) {
      await _processNotificationClick(details?.notificationResponse);
    }
  }

  Future<void> initializeLocalNotifications() async {
    if (!await Permission.notification.isGranted) {
      await Permission.notification.request();
    }
    var androidInitialize = AndroidInitializationSettings("notification");
    var iosInitialize = DarwinInitializationSettings();
    var initializationSettings = InitializationSettings(
      android: androidInitialize,
      iOS: iosInitialize,
    );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        await _processNotificationClick(response);
      },
    );
  }

  Future<void> _processNotificationClick(NotificationResponse? response) async {
    var payload = response?.payload;
    if (payload == null || payload.isEmpty) {
      return;
    }
    //final data = json.decode(payload);
  }
}

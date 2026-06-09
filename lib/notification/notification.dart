import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:quickpick/config/firebase_options.dart';

const _channelId = 'quickpick';
const _channelName = 'QuickPick';
const _vibrationPattern = [0, 150, 80, 150, 80, 300];

final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await _processFirebaseMessage(message);
}

Future<void> _processFirebaseMessage(RemoteMessage message) async {
  if (message.data.isEmpty) {
    return;
  }
  await _showLocalNotification(
    title: message.data['title'],
    body: message.data['body'],
  );
}

Future<void> _showLocalNotification({String? title, String? body}) async {
  const storage = FlutterSecureStorage();
  final notificationsEnabled = await storage.read(key: 'notifications') ?? '';
  if (notificationsEnabled == 'false') {
    return;
  }

  final details = NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId,
      _channelName,
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      vibrationPattern: Int64List.fromList(_vibrationPattern),
      enableVibration: true,
    ),
    iOS: const DarwinNotificationDetails(),
  );

  await flutterLocalNotificationsPlugin.show(
      id: 0, title: title, body: body, notificationDetails: details);
}

class QuickPickNotification {
  QuickPickNotification({required this.navigatorKey});

  final GlobalKey<NavigatorState> navigatorKey;

  Future<void> setup() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    await _initializeLocalNotifications();

    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission();

    if (!kIsWeb && Platform.isIOS) {
      await messaging.getAPNSToken();
    }

    await messaging.subscribeToTopic(_channelId);
    FirebaseMessaging.onMessage.listen(_processFirebaseMessage);
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    final launchDetails =
        await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp ?? false) {
      await _processNotificationClick(launchDetails?.notificationResponse);
    }
  }

  Future<void> _initializeLocalNotifications() async {
    if (!await Permission.notification.isGranted) {
      await Permission.notification.request();
    }

    await flutterLocalNotificationsPlugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('notification'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: _processNotificationClick,
    );

    await _resetNotificationChannel();
  }

  Future<void> _resetNotificationChannel() async {
    final androidPlugin =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.deleteNotificationChannel(channelId: _channelId);
    await androidPlugin?.createNotificationChannel(
      AndroidNotificationChannel(
        _channelId,
        _channelName,
        importance: Importance.max,
        vibrationPattern: Int64List.fromList(_vibrationPattern),
        enableVibration: true,
      ),
    );
  }

  Future<void> _processNotificationClick(NotificationResponse? response) async {
    final payload = response?.payload;
    if (payload == null || payload.isEmpty) {
      return;
    }
  }
}

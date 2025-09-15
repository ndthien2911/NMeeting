import 'dart:convert';
import 'package:nmeeting/configs/constants.dart';
import 'package:nmeeting/ui/router/app-router.dart';
import 'package:nmeeting/utilities/string-utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseNotificationService {
  static final FirebaseNotificationService _instance =
      FirebaseNotificationService._internal();
  factory FirebaseNotificationService() => _instance;
  FirebaseNotificationService._internal();

  final FirebaseMessaging messaging = FirebaseMessaging.instance;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  late AndroidNotificationChannel channel;

  RemoteMessage? _pendingMessage;

  Future<void> init() async {
    if (!kIsWeb) {
      channel = const AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        importance: Importance.high,
      );

      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

      var initializationSettingsAndroid =
          const AndroidInitializationSettings('@mipmap/launcher_icon');
      var initializationSettingsDarwin = const DarwinInitializationSettings();
      var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
      );

      flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onSelectNotification,
      );

      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // Lắng nghe tin nhắn foreground
      FirebaseMessaging.onMessage.listen(_handleMessage);

      // Lắng nghe khi bấm vào notification khi app background/terminated
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageClick);

      // Nếu app mở từ terminated state qua notification
      final initialMessage =
          await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        _handleMessageClick(initialMessage);
      }
    }
  }

  Future<void> _onSelectNotification(NotificationResponse response) async {
    if (StringUtils.isNullOrEmpty(response.payload)) return;

    var data = json.decode(response.payload!);
  }

  void _handleMessage(RemoteMessage message) {
    final notification = message.notification;
    final android = message.notification?.android;
    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            icon: android.smallIcon,
          ),
        ),
        payload: json.encode(message.data),
      );
    }
  }

  void _handleMessageClick(RemoteMessage message) {}
}

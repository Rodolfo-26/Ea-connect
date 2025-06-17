import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // 🔔 Canal necesario para Android >= 8.0
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'chat_channel',
    'Mensajes del chat',
    description: 'Canal para notificaciones de mensajes',
    importance: Importance.max,
  );

  static Future<void> initialize() async {
    await _requestPermission();
    await _initLocalNotifications();
    _setupOnMessageListener();
    await _printToken();
  }

  static Future<void> _requestPermission() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('✅ Notificaciones autorizadas');
    } else {
      debugPrint('❌ Notificaciones no autorizadas');
    }
  }

  static Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _localNotificationsPlugin.initialize(initSettings);

    // 🟡 Registro del canal de notificación (necesario para Android 8+)
    if (Platform.isAndroid) {
      await _localNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_channel);
    }
  }

  static void _setupOnMessageListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      final android = message.notification?.android;

      if (notification != null && android != null) {
        _localNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'chat_channel',
              'Mensajes del chat',
              channelDescription: 'Canal para notificaciones de mensajes',
              importance: Importance.max,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
            ),
          ),
        );
      }
    });
  }

  static Future<void> _printToken() async {
    final token = await _messaging.getToken();
    debugPrint('🔐 Token FCM: $token');
  }
}

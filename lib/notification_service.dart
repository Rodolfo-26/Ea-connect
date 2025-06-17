import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

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
    await _saveTokenToFirestore();
  }

  static Future<void> _requestPermission() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint(settings.authorizationStatus == AuthorizationStatus.authorized
        ? '✅ Notificaciones autorizadas'
        : '❌ Notificaciones no autorizadas');
  }

  static Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _localNotificationsPlugin.initialize(initSettings);

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

  static Future<void> _saveTokenToFirestore() async {
    final token = await _messaging.getToken();
    final user = FirebaseAuth.instance.currentUser;

    if (user != null && token != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'fcmToken': token,
      });

      debugPrint('🔐 Token guardado en Firestore: $token');
    }
  }
}

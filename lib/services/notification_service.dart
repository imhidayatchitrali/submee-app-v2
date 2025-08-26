import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:submee/network/dio_client.dart';
import 'package:submee/services/navigation_service.dart';
import 'package:submee/utils/logger.dart';
import 'package:submee/utils/preferences.dart';

// Firebase messaging background handler - needs to be a top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you initialize the service before using it
  await Firebase.initializeApp();

  print('Handling a background message: ${message.messageId}');
  // You could store the message in shared preferences or a local database
  // then handle it when the app is opened
}

// Notification service provider
final notificationServiceProvider = Provider<NotificationService>((ref) {
  final client = ref.watch(dioClient);
  final navigationController = ref.read(navigationStreamProvider);
  return NotificationService(
    dioClient: client,
    sendNavigationEvent: (String path) {
      navigationController.add(NavigationEvent(path));
    },
  );
});

class NotificationService {
  NotificationService({
    required this.dioClient,
    required this.sendNavigationEvent,
  });
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final DioClient dioClient;
  final Function(String) sendNavigationEvent;

  Future<void> _initialize() async {
    // Request permission
    await _fcm.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    // For iOS specifically, get the APNS token
    if (Platform.isIOS) {
      final apnsToken = await _fcm.getAPNSToken();
      Logger.d('APNS Token: $apnsToken');
    }

    // Initialize local notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/app_icon');

    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Set up background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle notification taps
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
  }

  void _onNotificationTapped(NotificationResponse response) {
    Logger.d('NotificationService ::: _onNotificationTapped');
    final data = jsonDecode(response.payload ?? '{}');
    final path = data['navigate_to'] ?? '/';
    Logger.d('Notification tapped on navigation to: $path');
    sendNavigationEvent(path);
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    Logger.d('NotificationService ::: _handleForegroundMessage');
    await _showLocalNotification(message);
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'GENERAL_NOTIFICATION_CHANNEL_ID',
      'General Notifications',
      channelDescription: 'General notifications for the app',
      importance: Importance.max,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics = DarwinNotificationDetails();

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      message.hashCode,
      message.notification?.title ?? 'Notification',
      message.notification?.body ?? '',
      platformChannelSpecifics,
      payload: jsonEncode(message.data),
    );
  }

  void _handleNotificationTap(RemoteMessage message) {
    Logger.d('Notification tapped: ${message.data}');
  }

  Future<String?> getFCMToken() async {
    return await _fcm.getToken();
  }

  Future<void> saveTokenToServer(String token) async {
    try {
      // Get device info
      final deviceInfo = DeviceInfoPlugin();
      Map<String, dynamic> deviceData = {};

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceData = {
          'device_id': androidInfo.id,
          'device_model': androidInfo.model,
          'device_brand': androidInfo.brand,
          'device_type': 'android',
          'app_version': Preferences.version + '+' + Preferences.buildNumber,
        };
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceData = {
          'device_id': iosInfo.identifierForVendor,
          'device_model': iosInfo.model,
          'device_brand': 'Apple',
          'device_type': 'ios',
          'app_version': Preferences.version + '+' + Preferences.buildNumber,
        };
      }

      // Save token to server
      final response = await dioClient.post(
        '/user/device',
        requireAuth: true,
        data: {
          'firebase_token': token,
          ...deviceData,
        },
      );

      if (response.statusCode == 200) {
        print('FCM Token saved to server successfully');
      } else {
        print('Failed to save FCM Token to server: ${response.statusCode}');
      }
    } catch (e) {
      print('Error saving FCM Token to server: $e');
    }
  }

  Future<void> setupNotifications() async {
    // Initialize notifications
    await _initialize();

    // Get FCM token
    final token = await getFCMToken();
    if (token != null) {
      print('FCM Token: $token');
      await saveTokenToServer(token);
    }

    // Listen for token refreshes
    _fcm.onTokenRefresh.listen((newToken) {
      print('FCM Token refreshed: $newToken');
      saveTokenToServer(newToken);
    });
  }

  Future<void> subscribeToTopic(String topic) async {
    await _fcm.subscribeToTopic(topic);
    print('Subscribed to topic: $topic');
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _fcm.unsubscribeFromTopic(topic);
    print('Unsubscribed from topic: $topic');
  }
}

import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:package_info/package_info.dart';
import 'package:rxdart/rxdart.dart';

class NotificationDelegate {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final _notificationSubject = PublishSubject<String?>();
  final _didReceiveLocalNotificationSubject = BehaviorSubject<ReceivedNotification>();

  Stream<String?> get stream => _notificationSubject;

  Future<bool> init() async {
    final initializationSettingsIOS = IOSInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
      onDidReceiveLocalNotification: onDidReceiveLocalNotification,
    );
    final initializationSettings = InitializationSettings(
        android: _kInitializationSettingsAndroid, iOS: initializationSettingsIOS);

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: false, sound: false);

    return await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings, onSelectNotification: selectNotification) ?? false;
  }

  Future<void> showNotification({required ReceivedNotification notification}) async {
    final packageInfo = await PackageInfo.fromPlatform();
    final androidPlatformChannelSpecifics = Platform.isIOS
        ? null
        : AndroidNotificationDetails(
      packageInfo.appName,
      _kChannelName + packageInfo.appName,
      channelDescription: _kChannelDescription,
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    final iOSPlatformChannelSpecifics = IOSNotificationDetails();
    final platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      notification.id,
      notification.title,
      notification.description,
      platformChannelSpecifics,
      payload: notification.payload,
    );
  }

  Future<dynamic> selectNotification(String? payload) async => _notificationSubject.add(payload);

  Future<dynamic> onDidReceiveLocalNotification(int id, String? title, String? body, String? payload) async =>
      _didReceiveLocalNotificationSubject.add(ReceivedNotification(id: id, title: title, description: body, payload: payload));
}

class ReceivedNotification {
  ReceivedNotification({
    required this.id,
    required this.title,
    required this.description,
    required this.payload,
  });

  final int id;
  final String? title;
  final String? description;
  final String? payload;
}

typedef OnNotificationClicked = void Function({required String payload});

const _kInitializationSettingsAndroid = AndroidInitializationSettings('ic_launcher_push');
const _kChannelName = 'firebase_';
const _kChannelDescription = '';

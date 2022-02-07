
import 'package:firebase_messaging/firebase_messaging.dart';

import 'notification_delegate.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message ${message.messageId}');
  try {
    final notificationDelegate = NotificationDelegate();
    await notificationDelegate.init();

    final pushDelegate = PushDelegate(notificationDelegate: notificationDelegate);
    await pushDelegate.init();

    await pushDelegate._messageHandler(message, notificationDelegate);
  } catch (exception) {
    print('_firebaseMessagingBackgroundHandler: ${await exception}');
  }
}

class PushDelegate {
  final NotificationDelegate notificationDelegate;

  PushDelegate({required this.notificationDelegate});

  Stream<String> get stream => notificationDelegate.stream.where((event) => event != null && event.isNotEmpty).map((event) => event!);

  Future<void> init() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen((event) => _messageHandler(event, notificationDelegate));
  }

  Future<dynamic> _messageHandler(RemoteMessage remoteMessage, NotificationDelegate notificationDelegate) async {
    print('_messageHandler, remoteMessage: $remoteMessage, data: ${remoteMessage.data}');
    await handleNotification(remoteMessage);
  }

  Future<void> handleNotification(RemoteMessage remoteMessage) async {
    var id;
    var title;
    var description;
    //final payload = PushRoutes.generateRoute(payload: remoteMessage.data);
    print('-------------------------------------');
    print(remoteMessage.data);
    print('-------------------------------------');

    if (remoteMessage.notification != null) {
      id = remoteMessage.notification.hashCode;
      title = remoteMessage.notification?.title;
      description = remoteMessage.notification?.body;
    } else if (remoteMessage.data.containsKey(_kPushNotification)) {
      final dynamic notification = remoteMessage.data[_kPushNotification];
      id = remoteMessage.data.hashCode;
      title = notification[_kPushNotificationTitle];
      description = notification[_kPushNotificationBody];
    }

    await notificationDelegate.showNotification(
      notification: ReceivedNotification(
        id: id,
        title: title,
        description: description,
        payload: 'PAYLOADDD',
      ),
    );
  }

  void requestNotificationPermissions() => FirebaseMessaging.instance.requestPermission();
}

const _kPushNotification = 'notification';
const _kPushNotificationTitle = 'title';
const _kPushNotificationBody = 'body';

import 'package:d2_ai_v2/models/unit.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:d2_ai_v2/services/firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseServices {

  static Future<void> initFirebaseApp() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }

}

class FireBaseCrashAnalytics {

  static Future<void> init() async {

  }

}

class FirebasePushHelper {

  static late final String? token;

  static Future<void> init() async {
    token = await FirebaseMessaging.instance.getToken();
    print(token);
  }
}

class FireBaseAnalytics {

  static Future<void> init() async {

    //FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  }

  static void registerTestEvent() async {
    await FirebaseAnalytics.instance
        .logEvent(
        name: 'app_started_event',
        parameters: {
          'current_time': DateTime.now().toString(),
        }
    );
  }

  static void onBattleStartedEvent({required List<Unit> units, required bool isPvE}) async {

    //FirebaseCrashlytics.instance.crash();

    final String battleType = isPvE ? 'PvE' : 'PvP';
    await FirebaseAnalytics.instance
        .logEvent(
        name: battleType + '_started_event',
        parameters: Map.fromIterables(List.generate(12, (index) => 'cell_$index'),
            List.generate(12, (index) => units[index].unitConstParams.unitName))
    );
  }

}
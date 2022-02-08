import 'package:d2_ai_v2/d2_entities/unit/unit_provider.dart';
import 'package:d2_ai_v2/screen/main_screen/main_game_screen.dart';
import 'package:d2_ai_v2/services/firebase.dart';
import 'package:d2_ai_v2/services/notification_delegate.dart';
import 'package:d2_ai_v2/services/push_delegate.dart';
import 'package:d2_ai_v2/styles.dart';
import 'package:d2_ai_v2/utils/svg_picture.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';


void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  /*final a = GameRepository(
      gimmuCProvider: GimmuCProvider(),
      gimmuProvider: GimmuProvider(),
      gattacksProvider: GattacksProvider(),
      gunitsProvider: GunitsProvider(),
      gtransfProvider: GtransfProvider(),
      gDynUpgrProvider: GDynUpgrProvider(),
      tglobalProvider: TglobalProvider());
  a.init();

  print(a.gunitsProvider.objects.length);*/

  //await DBFUnitsProvider(assetsPath: 'assets/dbf/smns_path_0_999/Globals/Gunits.dbf').init();

  //final test = FileUnitsProvider(filePath: 'asfd');
  //await test.init();



  await FirebaseServices.initFirebaseApp();
  await FireBaseAnalytics.init();
  //FireBaseAnalytics.registerTestEvent();

  //await FirebasePushHelper.init();
  final pushDelegate = await initializePush();
  //FirebaseCrashlytics.instance.recordError('testError', StackTrace.empty);
  //FirebaseCrashlytics.instance.log('LOG MESSAGE');
  runApp(const D2AiApp());
}


Future<PushDelegate> initializePush() async {

  FirebasePushHelper.init();

  final notificationDelegate = NotificationDelegate();
  await notificationDelegate.init();

  final pushDelegate = PushDelegate(notificationDelegate: notificationDelegate);
  await pushDelegate.init();

  return pushDelegate;
}

class D2AiApp extends StatelessWidget {
  const D2AiApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const D2AiAppBody());
  }
}


class D2AiAppBody extends StatefulWidget {
  const D2AiAppBody({Key? key}) : super(key: key);

  @override
  State<D2AiAppBody> createState() => _D2AiAppBodyState();
}

class _D2AiAppBodyState extends State<D2AiAppBody> {

  int selectedIndex = 0;

  late final Widget mainGamePage;

  @override
  void initState() {

    FirebaseMessaging.onMessage.listen((event) {
      print(event);
    });
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      print(event);
    });

    mainGamePage = Container(
      color: Colors.black,
      child: MainGameScreen()
      ,);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      /*appBar: AppBar(
        title: const Text("Disciples 2 clicker"),
      ),*/
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: selectedIndex,
        items: const [
          BottomNavigationBarItem(
            icon: SvgIcon(asset: 'ic_ai.svg', size: 30, color: null,),
            //title: Text("Битва", style: GameStyles.getMainTextStyle(),),
            label: "Битва",
          ),
          BottomNavigationBarItem(
            icon: SvgIcon(asset: 'ic_analytics.svg', size: 30, color: null,),
            //title: Text("Анализ", style: GameStyles.getMainTextStyle(),),
            label: "Анализ",
          ),
          /*BottomNavigationBarItem(
            icon: const SvgIcon(asset: 'ic_training.svg', size: 30, color: null,),
            title: Text("Тренировки", style: GameStyles.getMainTextStyle(),),
          ),
          BottomNavigationBarItem(
            icon: const SvgIcon(asset: 'ic_leaderboard.svg', size: 30, color: null,),
            title: Text("Рейтинг", style: GameStyles.getMainTextStyle(),),
          ),*/
          /*BottomNavigationBarItem(
            icon: const SvgIcon(asset: 'ic_profile.svg', size: 30, color: null,),
            title: Text("Настройки", style: GameStyles.getMainTextStyle(),),
          ),*/
        ],
        onTap: (int index) {
          onTapHandler(index);
        },

      ),
      body: getBody(),
    );

    // MainGameScreen
  }

  void onTapHandler(int index)  {
    setState(() {
      selectedIndex = 0;
    });
  }

  Widget getBody( )  {
    if (selectedIndex == 0) {
      return mainGamePage;
    } else if(selectedIndex == 1) {
      return Container(color: Colors.green,);
    } else if(selectedIndex == 2) {
      return Container(color: Colors.blue,);
    } else if(selectedIndex == 3) {
      return Container(color: Colors.blue,);
    } else if(selectedIndex == 4) {
      return Container(color: Colors.blue,);
    } else {
      throw Exception();
    }
  }
}




import 'package:d2_ai_v2/ai_controller/ai_contoller.dart';
import 'package:d2_ai_v2/ai_controller/ai_controller_ab_pruning.dart';
import 'package:d2_ai_v2/bloc/bloc.dart';
import 'package:d2_ai_v2/controllers/attack_controller/attack_controller.dart';
import 'package:d2_ai_v2/controllers/damage_scatter.dart';
import 'package:d2_ai_v2/controllers/duration_controller.dart';
import 'package:d2_ai_v2/controllers/power_controller.dart';
import 'package:d2_ai_v2/models/providers.dart';
import 'package:d2_ai_v2/repositories/game_repository.dart';
import 'package:d2_ai_v2/run_genetic_algorithm.dart';
import 'package:d2_ai_v2/screen/main_game_screen.dart';
import 'package:d2_ai_v2/styles.dart';
import 'package:d2_ai_v2/utils/math_utils.dart';
import 'package:d2_ai_v2/utils/svg_picture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/events.dart';
import 'bloc/states.dart';

import 'controllers/game_controller/game_controller.dart';
import 'controllers/initiative_shuffler.dart';

void main() async {
  runApp(const D2AiApp());
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
        items: [
          BottomNavigationBarItem(
            icon: const SvgIcon(asset: 'ic_ai.svg', size: 30, color: null,),
            title: Text("Битва", style: GameStyles.getMainTextStyle(),),
          ),
          BottomNavigationBarItem(
            icon: const SvgIcon(asset: 'ic_analytics.svg', size: 30, color: null,),
            title: Text("Анализ", style: GameStyles.getMainTextStyle(),),
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
      selectedIndex = index;
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




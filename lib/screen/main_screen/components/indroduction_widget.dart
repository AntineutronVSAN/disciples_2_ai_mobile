

import 'package:d2_ai_v2/theme/text.dart';
import 'package:flutter/material.dart';

import '../../../styles.dart';

class IntroductionWidget extends StatelessWidget {
  const IntroductionWidget({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ThemeAppText(
          style: GameStyles.informationWhiteStyle(),
          text: 'Старт - начать игру против самого себя',),
        ThemeAppText(
          style: GameStyles.informationWhiteStyle(),
          text: 'Старт с ИИ - начать игру против ИИ',),
        ThemeAppText(
          style: GameStyles.informationWhiteStyle(),
          text: 'Сброс - очистить все ячейки',),
        ThemeAppText(
          style: GameStyles.informationWhiteStyle(),
          text: 'Длительное нажатие на ячейку - открыть информацию о юните',),
      ],
    );
  }




}
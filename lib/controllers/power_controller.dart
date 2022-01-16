

import 'dart:math';

import 'package:d2_ai_v2/models/attack.dart';
import 'package:d2_ai_v2/utils/math_utils.dart';

/// Класс отвечает за точность, так как она в игре довольно своеобразная
class PowerController {

  final random = Random();

  final RandomExponentialDistribution randomExponentialDistribution;

  PowerController({required this.randomExponentialDistribution});

  bool applyAttack(UnitAttack attack, {required bool rollMaxPower}) {

    if (rollMaxPower) {
      return true;
    }

    final attackPower = attack.power;

    assert(attackPower >= 0 && attackPower <= 100);

    final nextRandom = randomExponentialDistribution.getNextInt(100, lambda: 2.5);

    //return true; // todo Убрать

    return attackPower > nextRandom;

  }

}
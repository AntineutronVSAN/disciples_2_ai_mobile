

import 'dart:math';

import 'package:d2_ai_v2/models/attack.dart';

class AttackDurationController {

  final random = Random();

  int getDuration(UnitAttack attack) {

    if (!attack.attackConstParams.infinite) {
      return 1;
    }

    return random.nextInt(3) + 1;

  }

}
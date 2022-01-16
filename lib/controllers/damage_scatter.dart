

import 'dart:math';

import 'package:d2_ai_v2/utils/math_utils.dart';

class DamageScatter {

  static const int maxScatterValue = 9;

  final random = Random();
  final RandomExponentialDistribution randomExponentialDistribution;

  DamageScatter({required this.randomExponentialDistribution});

  /// Если [rollMaxDamage], то при рассчёте берётся всегда максимальный разброс
  int getScattedDamage(int damage, {required bool rollMaxDamage}) {
    //return damage + random.nextInt(maxScatterValue);
    if (rollMaxDamage) {
      return damage + maxScatterValue;
    }
    return damage + randomExponentialDistribution.getNextInt(maxScatterValue);
  }

}


import 'dart:math';

import 'package:d2_ai_v2/utils/math_utils.dart';

class DamageScatter {

  static const int maxScatterValue = 9;

  final random = Random();
  final RandomExponentialDistribution randomExponentialDistribution;

  DamageScatter({required this.randomExponentialDistribution});

  int getScattedDamage(int damage) {
    //return damage + random.nextInt(maxScatterValue);
    return damage + randomExponentialDistribution.getNextInt(maxScatterValue);
  }

}


import 'dart:math';

class RandomExponentialDistribution {

  final random = Random();

  /// Коэффициент для игрока
  //static const playerLambda = 5.0;
  static const playerLambda = 4.0;
  /// Коэффициент для AI
  static const AILambda = 3.0;

  // x = log(1-u)/(-λ),

  /// Получить следующее целой число из экспоненциального распределения
  /// Мксимальное значение определяется [maxVal]
  /// Для корректировки используется [lambda]
  int getNextInt(int maxVal, {double lambda = playerLambda}) {

    double val = random.nextDouble();

    val = log(1-val)/(-lambda);

    final result = (val * maxVal).toInt();

    assert(result >= 0);

    return result <= maxVal ? result : maxVal;

  }

  void test2() {
    for(var i=0; i<1000; i++) {
      print(getNextInt(10));
    }
  }

}
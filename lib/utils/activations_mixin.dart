import 'dart:math';

import 'package:collection/src/iterable_extensions.dart';

typedef Activation = List<double> Function(List<double> v);

mixin MathMixin {
  final random = Random();

  List<double> sigmoid(List<double> inp) {
    return inp.map((el) {
      return (1 / (1 + pow(e, -el)));
    }).toList();
  }

  List<double> elu(List<double> inp) {
    return inp.map((el) {
      if (el > 0.0) {
        return el;
      }
      if (el == 0.0) {
        return 0.0;
      }
      return 0.2 * (pow(e, el) - 1.0);
    }).toList();
  }

  List<double> th(List<double> inp) {
    return inp.map((el) {
      return (pow(e, 2.0 * el) - 1.0) / (pow(e, 2.0 * el) + 1.0);
    }).toList();
  }

  List<double> relu(List<double> inp) {
    return inp.map((el) => (el < 0.0 ? 0.0 : el)).toList();
  }

  List<double> lrelu(List<double> inp) {
    return inp.map((el) => (el < 0.0 ? 0.25 * el : el)).toList();
  }

  List<double> softmax(List<double> inp) {
    final expVec = inp.map((value) => pow(e, value) * 1.0).toList();
    final sum = expVec.sum;
    final res = expVec.map((e) {
      if (sum == 0.0) {
        throw Exception();
      }
      return e / sum;
    }).toList();
    return res;
  }

  List<double> noneFunc(List<double> inp) {
    return inp.map((e) => e).toList();
  }

  double getRandomValue() {
    return (random.nextInt(2000) - 1000.0) / 1000.0;
  }

  Activation activationFunctionFromString(String str) {
    switch (str) {
      case 'sigmoid':
        return sigmoid;
      case 'softmax':
        return softmax;
      case 'relu':
        return relu;
      case 'lrelu':
        return lrelu;
      case 'th':
        return th;
      case 'elu':
        return elu;
      case 'none':
        return noneFunc;
    }
    throw Exception('Неизвестная активация');
  }
}

/// Равновероятный вызов одной из функций списка funcs
void callRandomFunc(List<Function()> funcs, Random random) {
  if (funcs.isEmpty) {
    return;
  }
  final funcCount = funcs.length;

  final randomValue = random.nextInt(1000);

  final rangesStep = 1000 ~/ funcCount;

  for (var i = 0; i < funcCount; i++) {
    if ((randomValue > i * rangesStep) &&
        (randomValue <= (i + 1) * rangesStep)) {
      funcs[i]();
      return;
    }
  }

  funcs.last();
  return;
}

T getRandomElement<T>(List<T> values, Random random) {
  final randomIndex = random.nextInt(values.length);
  return values[randomIndex];
}

double getRandomValue(Random random) {
  final rnd = random.nextDouble();
  return rnd;
}

double randomRange(double start, double end, Random random) {
  if (start >= end) {
    throw Exception();
  }
  final randomValue = start + random.nextDouble()*(end-start);
  return randomValue;
}

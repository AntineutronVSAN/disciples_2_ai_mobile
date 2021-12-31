import 'dart:math';

import 'package:collection/src/iterable_extensions.dart';

typedef Activation = List<double> Function(List<double> v);

mixin MathMixin {

  final random = Random();

  List<double> sigmoid(List<double> inp) {
    return inp.map((el) {

      if (el == 0.0) {
        return 0.0;
      }
      if (el == 1.0) {
        return 1.0;
      }

      return (1 / (1 - pow(e, el)));
    }).toList();
  }

  List<double> relu(List<double> inp) {
    return inp.map((el) => (el < 0.0 ? 0.0 : el)).toList();
  }

  List<double> softmax(List<double> inp) {

    final expVec = inp.map((value) => pow(e, value)*1.0).toList();
    final sum = expVec.sum;
    final res = expVec.map((e) {
      if (sum == 0.0) {
        throw Exception();
      }
      return e/sum;
    }).toList();
    return res;
  }

  List<double> noneFunc(List<double> inp) {
    return inp.map((e) => e).toList();
  }

  double getRandomValue() {
    return (random.nextInt(2000) - 1000.0)/1000.0;
  }

  Activation activationFunctionFromString(String str) {
    switch(str) {
      case 'sigmoid':
        return sigmoid;
      case 'softmax':
        return softmax;
      case 'relu':
        return relu;
      case 'none':
        return noneFunc;
    }
    throw Exception('Неизвестная активация');

  }
}

String getRandomActivation() {

  final rnd = Random().nextInt(2);
  switch(rnd) {
    case 0:
      return 'sigmoid';
    case 1:
      return 'relu';
  }
  throw Exception();
}

double getRandomValue() {

  final rnd = Random().nextDouble();
  return rnd;
}
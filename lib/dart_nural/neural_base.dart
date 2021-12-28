

import 'dart:math';

import 'package:ml_linalg/vector.dart';


typedef Activation = Function(Vector v);

abstract class GameNeuralNetworkBase {
  List<double> forward(List<double> inputData);

  final random = Random();

  List<double> getWeights();
  List<double> getBiases();
  List<String> getActivations();

  Vector sigmoid(Vector inp) {
    return inp.mapToVector((el) => (1 / (1 - pow(e, el))));
  }

  Vector relu(Vector inp) {
    return inp.mapToVector((el) => (el < 0.0 ? 0.0 : el));
  }

  Vector softmax(Vector inp) {

    final expVec = inp.mapToVector((value) => pow(e, value)*1.0);
    final sum = expVec.sum();
    final res = expVec / sum;
    return res;
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
    }
    throw Exception('Неизвестная активация');

  }
}


import 'dart:math';

import 'package:ml_linalg/vector.dart';

abstract class GameNeuralNetworkBase {
  List<double> forward(List<double> inputData);

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
}

import 'package:collection/src/iterable_extensions.dart';
import 'package:ml_linalg/linalg.dart';
import 'package:ml_linalg/matrix.dart';
import 'package:json_annotation/json_annotation.dart';
import 'dart:math';


// https://pub.dev/packages/ml_linalg#matrix-operations-examples

typedef Activation = Function(Vector v);


class SimpleLinearNeuralNetwork {

  final List<double> weights = [];
  final List<Matrix> _weightsMatrix = [];

  final List<double> biases = [];

  /// Список активационных функций слоя
  final List<String> _layerActivations = [];

  final int input;
  final int output;
  final int hidden;
  final int layers;

  /// Какое максимальное значение у ВСЕХ данных входного верктора
  late final int? maxVal;

  final random = Random();

  SimpleLinearNeuralNetwork({
    required this.input,
    required this.output,
    required this.hidden,
    required this.layers,
    List<double>? startWeights,
    List<String>? startActivations,
    List<double>? startBiases,
  }) {
    if (startWeights == null) {

      // todo Проверить, что все начальные значения не равны 0

      for(var i=0; i<input*hidden; i++) {
        weights.add((random.nextInt(2000) - 1000.0)/1000.0);
      }
      biases.addAll(List.generate(hidden, (index) => (random.nextInt(2000) - 1000.0)/1000.0));
      for(var hc=0; hc<layers; hc++) {
        for(var i=0; i<hidden*hidden; i++) {
          weights.add((random.nextInt(2000) - 1000.0)/1000.0);
        }
        biases.addAll(List.generate(hidden, (index) => (random.nextInt(2000) - 1000.0)/1000.0));
      }
      for(var i=0; i<hidden*output; i++) {
        weights.add((random.nextInt(2000) - 1000.0)/1000.0);
      }
      biases.addAll(List.generate(output, (index) => (random.nextInt(2000) - 1000.0)/1000.0));
    } else {
      assert(startWeights.length == (input*hidden + hidden*hidden*layers + hidden*output));
      //assert(startActivations!.length == layers - 1); // Полчему не -2? Потому что активация выходного слоя всегда softmax
      weights.addAll(startWeights);
      biases.addAll(startBiases!);

    }

    _weights2matrix(startActivations);
  }


  /*factory SimpleLinearNeuralNetwork.from({
    required List<int> weights,
    required int input,
    required int output,
    required int hidden,
    required int layers,
  }) {
   return
  }*/


  /// Преобразовать вектор весов [weights] в список матриц [_weightsMatrix]
  /// в соответствии со слоями.
  /// Тяжалейшая операция! Не рекомендуется использовтаь часто
  void _weights2matrix(List<String>? startActivations) {

    final matrixCount = layers + 2; // 2 - входной и выходной слой

    // todo docs Строка матрицы весов - input

    // Текущее положение каретки на весах
    int caretPos = 0;

    for(var i=0; i<matrixCount; i++) {
      if (i == 0) {
        List<List<double>> currentMatrix = [];
        // Входной - скрытый
        for(var hiddenCount=0; hiddenCount<hidden; hiddenCount++) {
          List<double> currentMatrixRow = [];

          for(var inputCount=0; inputCount<input; inputCount++) {
            currentMatrixRow.add(weights[caretPos]);
            caretPos++;
          }
          currentMatrix.add(currentMatrixRow);
        }
        _weightsMatrix.add(Matrix.fromList(currentMatrix));
        if (startActivations != null) {
          _layerActivations.add(startActivations[i]);
        } else {
          _layerActivations.add('sigmoid');
        }


      } else if (i == matrixCount - 1) {
        List<List<double>> currentMatrix = [];
        // Скрытый - выходной
        for(var outputCount=0; outputCount<output; outputCount++) {
          List<double> currentMatrixRow = [];

          for(var hiddenCount=0; hiddenCount<hidden; hiddenCount++) {
            currentMatrixRow.add(weights[caretPos]);
            caretPos++;
          }
          currentMatrix.add(currentMatrixRow);
        }
        _weightsMatrix.add(Matrix.fromList(currentMatrix));
        _layerActivations.add('softmax');


      } else {
        // Скрытый - скрытый
        List<List<double>> currentMatrix = [];
        // Скрытый - выходной
        for(var lastHiddenCount=0; lastHiddenCount<hidden; lastHiddenCount++) {
          List<double> currentMatrixRow = [];

          for(var hiddenCount=0; hiddenCount<hidden; hiddenCount++) {
            currentMatrixRow.add(weights[caretPos]);
            caretPos++;
          }
          currentMatrix.add(currentMatrixRow);
        }
        _weightsMatrix.add(Matrix.fromList(currentMatrix));
        if (startActivations != null) {
          _layerActivations.add(startActivations[i]);
        } else {
          _layerActivations.add('sigmoid');
        }
      }

    }

    assert(caretPos == weights.length);
  }


  List<double> forward(List<double> inputData) {

    assert(inputData.length == input, '${inputData.length} != $input');

    /*assert(biases.length == List.generate(_weightsMatrix.length, (index) =>
      _weightsMatrix[index].rows.length).sum);*/

    if (biases.length != List.generate(_weightsMatrix.length, (index) =>
    _weightsMatrix[index].rows.length).sum) {
      print('${biases.length} != ${List.generate(_weightsMatrix.length, (index)
      => _weightsMatrix[index].rows.length).sum}');
      assert(false);
    }

    Vector inputVector = Vector.fromList(inputData);
    Matrix currentMatrix = Matrix.fromColumns([inputVector]);

    int biasesCaretPos = 0;
    for(var i=0; i<_weightsMatrix.length; i++) {

      currentMatrix = _weightsMatrix[i] * currentMatrix;
      // К выходу прибавляются веса смещения
      final curVectorBiases = biases.sublist(biasesCaretPos, biasesCaretPos + _weightsMatrix[i].rows.length);
      biasesCaretPos += _weightsMatrix[i].rows.length;
      currentMatrix += Matrix.fromColumns([Vector.fromList(curVectorBiases)]);
      currentMatrix = currentMatrix.mapColumns((column) => _activationFunctionFromString(_layerActivations[i])(column));

    }
    final outputVector = currentMatrix.transpose()[0];

    return outputVector.toList();

  }


  Activation _activationFunctionFromString(String str) {
    switch(str) {
      case 'sigmoid':
        return _sigmoid;
      case 'softmax':
        return _softmax;
      case 'relu':
        return _relu;
    }
    throw Exception('Неизвестная активация');

  }

  Vector _sigmoid(Vector inp) {
    return inp.mapToVector((el) => (1 / (1 - pow(e, el))));
  }

  Vector _relu(Vector inp) {
    return inp.mapToVector((el) => (el < 0.0 ? 0.0 : el));
  }

  Vector _softmax(Vector inp) {

    final expVec = inp.mapToVector((value) => pow(e, value)*1.0);
    final sum = expVec.sum();
    final res = expVec / sum;
    return res;
  }
}
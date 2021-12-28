

import 'dart:math';

import 'package:collection/src/iterable_extensions.dart';
import 'package:ml_linalg/matrix.dart';
import 'package:ml_linalg/vector.dart';

import 'neural_base.dart';

/// Многослойный персептрон. Является сборочной единицей для
/// более сложных архитектур, но так же может использоваться как
/// самостоятельная единица
class MultilayerPerceptron extends GameNeuralNetworkBase {

  /// Веса в виде вектора
  final List<double> _weights = [];
  /// Веса в виде матриц
  final List<Matrix> _weightsMatrix = [];
  /// Веса смещения в виде вектора
  final List<double> _biases = [];

  /// Список активационных функций слоя
  final List<String> _layerActivations = [];

  final int input;
  final int output;
  /// Список скрытых слоёв, где значение в списке - число нейронов в слое, а
  /// индекс элемента номер скрытого слоя. Например, если [_layers] = [7,4,5]
  /// то архитектура персептрона будет следующей [input, 7, 4, 5, output]
  final List<int> layers;

  final bool initFrom;

  MultilayerPerceptron({
    required this.input,
    required this.output,
    required this.layers,
    required this.initFrom,
    required List<double>? startWeights,
    required List<double>? startBiases,
    required List<String>? startActivations,
  }) {

    if (initFrom) {
      assert(
      startWeights != null &&
      startBiases != null &&
      startActivations != null
      );
      _initFrom(
          startWeights: startWeights!,
          startBiases: startBiases!,
          startActivations: startActivations!);
    } else {
      _initRandom();
    }

  }

  void _initRandom() {
    //  Первый слой
    for(var i=0; i<layers.first*input; i++) {
      _weights.add(getRandomValue());
    }
    _biases.addAll(List.generate(layers.first, (index) => getRandomValue()));

    // Скрытые слои
    // l - layer
    // hcn - hiddenCountNext
    // hc - hiddenCountCurrent
    for(var l=0; l<layers.length-1;l++) {
      for(var hcn=0; hcn<layers[l+1]; hcn++) {
        for(var hc=0; hc<layers[l]; hc++) {
          _weights.add(getRandomValue());
        }
      }
      _biases.addAll(List.generate(layers[l+1], (index) => getRandomValue()));
    }

    // Выходной слой
    for(var i=0; i<output*layers.last; i++) {
      _weights.add(getRandomValue());
    }
    _biases.addAll(List.generate(output, (index) => getRandomValue()));
    _weights2matrix();
  }

  /// Инициализировать параметры персептрона из данных
  void _initFrom({
    required List<double> startWeights,
    required List<double> startBiases,
    required List<String> startActivations,
  }) {
    _weights.addAll(startWeights);
    _biases.addAll(startBiases);
    _layerActivations.addAll(startActivations);
    _weights2matrix();
  }

  /// Инициализировать параметры персептрона случайным образом
  void _weights2matrix() {

    assert(_weights.isNotEmpty);
    assert(_biases.isNotEmpty);
    if (initFrom) {
      assert(_layerActivations.isNotEmpty);
    }

    final matrixCount = layers.length + 1; // 2 - входной и выходной слой
    // Текущее положение каретки на весах
    int caretPos = 0;

    for(var i=0; i<matrixCount; i++) {
      if (i == 0) {
        List<List<double>> currentMatrix = [];
        // Входной - скрытый
        for(var hiddenCount=0; hiddenCount<layers.first; hiddenCount++) {
          List<double> currentMatrixRow = [];

          for(var inputCount=0; inputCount<input; inputCount++) {
            currentMatrixRow.add(_weights[caretPos]);
            caretPos++;
          }
          currentMatrix.add(currentMatrixRow);
        }
        _weightsMatrix.add(Matrix.fromList(currentMatrix));
        if (!initFrom) {
          _layerActivations.add('sigmoid');
        }
      } else if (i == matrixCount - 1) {
        List<List<double>> currentMatrix = [];
        // Скрытый - выходной
        for(var outputCount=0; outputCount<output; outputCount++) {
          List<double> currentMatrixRow = [];
          for(var hiddenCount=0; hiddenCount<layers.last; hiddenCount++) {
            currentMatrixRow.add(_weights[caretPos]);
            caretPos++;
          }
          currentMatrix.add(currentMatrixRow);
        }
        _weightsMatrix.add(Matrix.fromList(currentMatrix));
        if (!initFrom) {
          _layerActivations.add('softmax');
        }
      } else {
        // Скрытый - скрытый
        List<List<double>> currentMatrix = [];
        for(var lastHiddenCount=0; lastHiddenCount<layers[i]; lastHiddenCount++) {
          List<double> currentMatrixRow = [];
          for(var hiddenCount=0; hiddenCount<layers[i-1]; hiddenCount++) {
            currentMatrixRow.add(_weights[caretPos]);
            caretPos++;
          }
          currentMatrix.add(currentMatrixRow);
        }
        _weightsMatrix.add(Matrix.fromList(currentMatrix));
        if (!initFrom) {
          _layerActivations.add('sigmoid');
        }
        /*for(var hl=0; hl<layers.length-1; hl++) {

          List<List<double>> currentMatrix = [];
          for(var lastHiddenCount=0; lastHiddenCount<layers[hl+1]; lastHiddenCount++) {
            List<double> currentMatrixRow = [];
            for(var hiddenCount=0; hiddenCount<layers[hl]; hiddenCount++) {
              currentMatrixRow.add(_weights[caretPos]);
              caretPos++;
            }
            currentMatrix.add(currentMatrixRow);
          }
          _weightsMatrix.add(Matrix.fromList(currentMatrix));
          if (!initFrom) {
            _layerActivations.add('sigmoid');
          }
        }*/
      }

    }

    assert(caretPos == _weights.length);

  }

  @override
  List<double> forward(List<double> inputData) {

    assert(inputData.length == input, '${inputData.length} != $input');

    if (_biases.length != List.generate(_weightsMatrix.length, (index) =>
    _weightsMatrix[index].rows.length).sum) {
      print('${_biases.length} != ${List.generate(_weightsMatrix.length, (index)
      => _weightsMatrix[index].rows.length).sum}');
      assert(false);
    }

    Vector inputVector = Vector.fromList(inputData);
    Matrix currentMatrix = Matrix.fromColumns([inputVector]);

    int biasesCaretPos = 0;
    for(var i=0; i<_weightsMatrix.length; i++) {

      currentMatrix = _weightsMatrix[i] * currentMatrix;
      // К выходу прибавляются веса смещения
      final curVectorBiases = _biases.sublist(biasesCaretPos, biasesCaretPos + _weightsMatrix[i].rows.length);
      biasesCaretPos += _weightsMatrix[i].rows.length;
      currentMatrix += Matrix.fromColumns([Vector.fromList(curVectorBiases)]);
      currentMatrix = currentMatrix.mapColumns((column) => activationFunctionFromString(_layerActivations[i])(column));

    }
    final outputVector = currentMatrix.transpose()[0];

    return outputVector.toList();
  }

  @override
  List<String> getActivations() {
    return _layerActivations;
  }

  @override
  List<double> getBiases() {
    return _biases;
  }

  @override
  List<double> getWeights() {
    return _weights;
  }

}
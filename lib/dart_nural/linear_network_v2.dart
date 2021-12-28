
/*

Суть данной нейронной сети:

Для вектора юнита и его атак создаётся нейронная сеть, общая для всех юнитов.

Вектор каждого юнита преобразуется в карту признаков юнитовской нейронной сетью,
затем эти карты признаков суммируются (или перемножаются или ещё что-то)
и отправляются в ещё одну нейронную сеть, которая уже на выходе выдаёт
действие.

*/


import 'dart:math';

import 'package:ml_linalg/matrix.dart';

import 'neural_base.dart';

class LinearNeuralNetworkV2 extends GameNeuralNetworkBase {

  // ----- Нейронная сеть для карты признаков юнита и его характеристик
  List<double> unitsNeuralNetworkWeights = [];
  List<double> unitsNeuralNetworkBiases = [];
  List<String> unitsNeuralNetworkActivations = [];
  /// Сколько нейронов в скрытом слоё. Длина списка [hiddenLayers] это
  /// число слоёв
  final List<int> unitNnHiddenLayers;
  final List<Matrix> _unitWeightsMatrix = [];

  // ----- Нейронная сеть для принятия решения
  List<double> neuralNetworkWeights = [];
  List<double> neuralNetworkBiases = [];
  List<String> neuralNetworkActivations = [];
  /// Сколько нейронов в скрытом слоё. Длина списка [hiddenLayers] это
  /// число слоёв
  final List<int> nnHiddenLayers;
  final List<Matrix> _weightsMatrix = [];

  final int input;
  final int output;

  final int unitsCount;

  final random = Random();

  LinearNeuralNetworkV2({
    required this.output,
    required this.input,
    required this.nnHiddenLayers,
    required this.unitNnHiddenLayers,
    required this.unitsCount,
    List<double>? startWeights,
    List<String>? startActivations,
    List<double>? startBiases,
    List<double>? unitStartWeights,
    List<String>? unitStartActivations,
    List<double>? unitStartBiases,
    required bool initFrom,
  }) {
    assert(nnHiddenLayers.isNotEmpty);
    assert(unitNnHiddenLayers.isNotEmpty);
    if(initFrom) {
      assert(
        startWeights != null &&
        startActivations != null &&
        startBiases != null &&

        unitStartWeights != null &&
        unitStartActivations != null &&
        unitStartBiases != null
      );
      _initFromData(
          startWeights: startWeights!,
          startActivations: startActivations!,
          startBiases: startBiases!,
          unitStartWeights: unitStartWeights!,
          unitStartActivations: unitStartActivations!,
          unitStartBiases: unitStartBiases!);
    } else {
      _initRandom();
    }
  }

  /// Инициализировать веса случайным образом
  void _initRandom() {
    // ------------------------- Нейронная сеть юнитов

    for(var i=0; i<input*unitNnHiddenLayers[0]; i++) {
      unitsNeuralNetworkWeights.add(_getRandomValue());
    }
    unitsNeuralNetworkBiases.addAll(List.generate(unitNnHiddenLayers[0], (index) => _getRandomValue()));
    for(var hc=0; hc<unitNnHiddenLayers.length-1; hc++) {
      final int currentLayerNeuronsIndex = hc;
      final int nextLayerNeuronsIndex = hc + 1;
      for(var i=0; i<unitNnHiddenLayers[currentLayerNeuronsIndex]*unitNnHiddenLayers[nextLayerNeuronsIndex]; i++) {
        unitsNeuralNetworkWeights.add(_getRandomValue());
      }
      unitsNeuralNetworkBiases.addAll(List.generate(unitNnHiddenLayers[nextLayerNeuronsIndex], (index) => _getRandomValue()));
    }
    /*for(var i=0; i<unitNnHiddenLayers[unitNnHiddenLayers.last]*output; i++) {
      unitsNeuralNetworkWeights.add(_getRandomValue());
    }
    unitsNeuralNetworkBiases.addAll(List.generate(output, (index) => _getRandomValue()));*/

    // ------------------------- Нейронная сеть принятия решения
    // Вход нейронной сети принятия решения равен выходу нейронной сети юнитов
    final int neuralInput = unitNnHiddenLayers.last;

    for(var i=0; i<neuralInput*nnHiddenLayers[0]; i++) {
      neuralNetworkWeights.add(_getRandomValue());
    }
    neuralNetworkBiases.addAll(List.generate(nnHiddenLayers[0], (index) => _getRandomValue()));
    for(var hc=0; hc<nnHiddenLayers.length-1; hc++) {
      final int currentLayerNeuronsIndex = hc;
      final int nextLayerNeuronsIndex = hc + 1;
      for(var i=0; i<nnHiddenLayers[currentLayerNeuronsIndex]*nnHiddenLayers[nextLayerNeuronsIndex]; i++) {
        neuralNetworkWeights.add(_getRandomValue());
      }
      neuralNetworkBiases.addAll(List.generate(nnHiddenLayers[nextLayerNeuronsIndex], (index) => _getRandomValue()));
    }
    for(var i=0; i<nnHiddenLayers[nnHiddenLayers.last]*output; i++) {
      neuralNetworkWeights.add(_getRandomValue());
    }
    neuralNetworkBiases.addAll(List.generate(output, (index) => _getRandomValue()));

    _unitWeights2matrix();
    _weights2matrix();
  }

  /// Инициализировать веса с данных
  void _initFromData({
    required List<double> startWeights,
    required List<String> startActivations,
    required List<double> startBiases,
    required List<double> unitStartWeights,
    required List<String> unitStartActivations,
    required List<double> unitStartBiases,
  }) {

    final unitNnWeightsCount = unitStartWeights.length;
    int unitNeuralMustBe = 0;
    for(var i=0; i<unitNnHiddenLayers.length-1; i++) {
      unitNeuralMustBe += unitNnHiddenLayers[i]*unitNnHiddenLayers[i+1];
    }
    assert(unitNnWeightsCount == input*unitNnHiddenLayers[0] +
        unitNeuralMustBe
        //unitNnHiddenLayers.last*output
    );

    final nnWeightsCount = startWeights.length;
    int neuralMustBe = 0;
    for(var i=0; i<nnHiddenLayers.length-1; i++) {
      neuralMustBe += nnHiddenLayers[i]*nnHiddenLayers[i+1];
    }
    assert(nnWeightsCount == unitNnHiddenLayers.last*nnHiddenLayers[0] +
        neuralMustBe +
        nnHiddenLayers.last*output
    );

    neuralNetworkWeights.addAll(startWeights);
    neuralNetworkBiases.addAll(startBiases);

    unitsNeuralNetworkWeights.addAll(unitStartWeights);
    unitsNeuralNetworkBiases.addAll(unitStartBiases);

    _unitWeights2matrix(activations: unitStartActivations);
    _weights2matrix(activations: startActivations);
  }

  void _unitWeights2matrix({List<String>? activations}) {
    final matrixCount = unitNnHiddenLayers.length + 2;
    int caretPos = 0;
    for(var i=0; i<matrixCount; i++) {
      if (i == 0) {
        List<List<double>> currentMatrix = [];
        // Входной - скрытый
        for(var hiddenCount=0; hiddenCount<unitNnHiddenLayers.first; hiddenCount++) {
          List<double> currentMatrixRow = [];
          for(var inputCount=0; inputCount<input; inputCount++) {
            currentMatrixRow.add(unitsNeuralNetworkWeights[caretPos]);
            caretPos++;
          }
          currentMatrix.add(currentMatrixRow);
        }
        _unitWeightsMatrix.add(Matrix.fromList(currentMatrix));
        if (activations != null) {
          unitsNeuralNetworkActivations.add(activations[i]);
        } else {
          unitsNeuralNetworkActivations.add('sigmoid');
        }

      } else if (i == matrixCount - 1) {
        List<List<double>> currentMatrix = [];
        // Скрытый - выходной
        for(var outputCount=0; outputCount<output; outputCount++) {
          List<double> currentMatrixRow = [];

          for(var hiddenCount=0; hiddenCount<unitNnHiddenLayers.last; hiddenCount++) {
            currentMatrixRow.add(unitsNeuralNetworkWeights[caretPos]);
            caretPos++;
          }
          currentMatrix.add(currentMatrixRow);
        }
        _unitWeightsMatrix.add(Matrix.fromList(currentMatrix));
        unitsNeuralNetworkActivations.add('softmax');
      } else {
        // Скрытый - скрытый
        List<List<double>> currentMatrix = [];
        for(var j=0; j<unitNnHiddenLayers.length-1; j++) {
          final currentLayerIndex = j;
          final nextLayerIndex = j+1;
          for(var lastHiddenCount=0; lastHiddenCount<unitNnHiddenLayers[nextLayerIndex]; lastHiddenCount++) {
            List<double> currentMatrixRow = [];
            for(var hiddenCount=0; hiddenCount<unitNnHiddenLayers[currentLayerIndex]; hiddenCount++) {
              currentMatrixRow.add(unitsNeuralNetworkWeights[caretPos]);
              caretPos++;
            }
            currentMatrix.add(currentMatrixRow);
          }
          _unitWeightsMatrix.add(Matrix.fromList(currentMatrix));
          if (activations != null) {
            unitsNeuralNetworkActivations.add(activations[i]);
          } else {
            unitsNeuralNetworkActivations.add('sigmoid');
          }
        }
      }
    }
  }

  void _weights2matrix({List<String>? activations}) {
    final matrixCount = nnHiddenLayers.length + 2;
    int caretPos = 0;
    for(var i=0; i<matrixCount; i++) {
      if (i == 0) {
        List<List<double>> currentMatrix = [];
        // Входной - скрытый
        for(var hiddenCount=0; hiddenCount<nnHiddenLayers.first; hiddenCount++) {
          List<double> currentMatrixRow = [];
          for(var inputCount=0; inputCount<input; inputCount++) {
            currentMatrixRow.add(neuralNetworkWeights[caretPos]);
            caretPos++;
          }
          currentMatrix.add(currentMatrixRow);
        }
        _weightsMatrix.add(Matrix.fromList(currentMatrix));
        if (activations != null) {
          neuralNetworkActivations.add(activations[i]);
        } else {
          neuralNetworkActivations.add('sigmoid');
        }

      } else if (i == matrixCount - 1) {
        List<List<double>> currentMatrix = [];
        // Скрытый - выходной
        for(var outputCount=0; outputCount<output; outputCount++) {
          List<double> currentMatrixRow = [];

          for(var hiddenCount=0; hiddenCount<nnHiddenLayers.last; hiddenCount++) {
            currentMatrixRow.add(neuralNetworkWeights[caretPos]);
            caretPos++;
          }
          currentMatrix.add(currentMatrixRow);
        }
        _weightsMatrix.add(Matrix.fromList(currentMatrix));
        neuralNetworkActivations.add('softmax');
      } else {
        // Скрытый - скрытый
        List<List<double>> currentMatrix = [];
        for(var j=0; j<nnHiddenLayers.length-1; j++) {
          final currentLayerIndex = j;
          final nextLayerIndex = j+1;
          for(var lastHiddenCount=0; lastHiddenCount<nnHiddenLayers[nextLayerIndex]; lastHiddenCount++) {
            List<double> currentMatrixRow = [];
            for(var hiddenCount=0; hiddenCount<nnHiddenLayers[currentLayerIndex]; hiddenCount++) {
              currentMatrixRow.add(neuralNetworkWeights[caretPos]);
              caretPos++;
            }
            currentMatrix.add(currentMatrixRow);
          }
          _weightsMatrix.add(Matrix.fromList(currentMatrix));
          if (activations != null) {
            neuralNetworkActivations.add(activations[i]);
          } else {
            neuralNetworkActivations.add('sigmoid');
          }
        }
      }
    }
  }

  double _getRandomValue() {
    return (random.nextInt(2000) - 1000.0)/1000.0;
  }

  @override
  List<double> forward(List<double> inputData) {
    // TODO: implement forward
    throw UnimplementedError();
  }

}
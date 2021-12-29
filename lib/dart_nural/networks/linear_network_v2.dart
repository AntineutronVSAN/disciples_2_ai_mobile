
/*

Суть данной нейронной сети:

Для вектора юнита и его атак создаётся нейронная сеть, общая для всех юнитов.

Вектор каждого юнита преобразуется в карту признаков юнитовской нейронной сетью,
затем эти карты признаков суммируются (или перемножаются или ещё что-то)
и отправляются в ещё одну нейронную сеть, которая уже на выходе выдаёт
действие.

*/



import 'package:d2_ai_v2/dart_nural/multilayer_perceptron.dart';
import 'package:ml_linalg/linalg.dart';

import '../neural_base.dart';

class LinearNeuralNetworkV2 extends GameNeuralNetworkBase {

  final int input;
  final int output;

  final List<int> layers;
  final List<int> unitLayers;

  List<double> _weights = [];
  List<double> _biases = [];
  List<String> _activations = [];

  List<double> _unitWeights = [];
  List<double> _unitBiases = [];
  List<String> _unitActivations = [];

  bool initFrom;

  late final GameNeuralNetworkBase nn;
  late final GameNeuralNetworkBase unitNn;

  /// Сколько ячеек на поле боя
  final int cellsCount;

  /// Длина вектора юнитов
  final int unitVectorLength;

  LinearNeuralNetworkV2({
    required this.input,
    required this.output,
    required this.layers,
    required this.unitLayers,
    required this.initFrom,
    this.cellsCount=12,
    required this.unitVectorLength,
    required List<double>? startWeights,
    required List<double>? startBiases,
    required List<String>? startActivations,
    required List<double>? unitStartWeights,
    required List<double>? unitStartBiases,
    required List<String>? unitStartActivations,
  }) {

    if (initFrom) {
      assert(
        startWeights != null &&
        startBiases != null &&
        startActivations != null &&
        unitStartWeights != null &&
        unitStartBiases != null &&
        unitStartActivations != null
      );
    } else {
      assert(
      startWeights == null &&
      startBiases == null &&
      startActivations == null &&
      unitStartWeights == null &&
      unitStartBiases == null &&
      unitStartActivations == null
      );
    }

    unitNn = MultilayerPerceptron(
        input: input,
        output: unitLayers.last,
        layers: unitLayers,
        initFrom: initFrom,
        startWeights: unitStartWeights,
        startBiases: unitStartBiases,
        startActivations: unitStartActivations
    );

    nn = MultilayerPerceptron(
        input: unitLayers.last,
        output: output,
        layers: layers,
        initFrom: initFrom,
        startWeights: startWeights,
        startBiases: startBiases,
        startActivations: startActivations
    );

    _unitWeights = unitNn.getWeights()[0];
    _unitBiases = unitNn.getBiases()[0];
    _unitActivations = unitNn.getActivations()[0];

    _weights = nn.getWeights()[0];
    _biases = nn.getBiases()[0];
    _activations = nn.getActivations()[0];

  }

  @override
  List<double> forward(List<double> inputData) {
    final List<Vector> unitNetworksOutput = [];
    assert(inputData.length == cellsCount*unitVectorLength, "${inputData.length} != ${cellsCount*unitVectorLength}");

    final inputVector = Vector.fromList(inputData);

    //Stopwatch stopwatch = Stopwatch()..start();
    // Выходы нейронной сети, преобразующей юнитов
    for(var i=0; i<cellsCount; i++) {
      //stopwatch.reset();
      //final currentUnitVector = inputData.sublist(i*unitVectorLength, (i+1)*unitVectorLength);
      final currentUnitVector = inputVector.subvector(i*unitVectorLength, (i+1)*unitVectorLength);

      //print('Саблист ${stopwatch.elapsed}');
      //stopwatch.reset();
      unitNetworksOutput.add(unitNn.forwardRetVectorFromVector(currentUnitVector));
      //print('Проход ${stopwatch.elapsed}');
    }

    // ------------ Выходы суммируются // todo Возможно что-то другое помимо суммы
    Vector sum = Vector.zero(unitLayers.last);
    for(var i=0; i<cellsCount; i++) {
      sum += unitNetworksOutput[i];
    }
    final netOutput = nn.forward(sum.toList());
    // ------------- Конкатенация выходов axis=0
    /*List<double> concatenated = [];
    for(var i=0; i<cellsCount; i++) {
      concatenated.addAll(unitNetworksOutput[i]);
    }
    final netOutput = nn.forward(concatenated)*/

    return netOutput;
  }

  @override
  List<List<String>> getActivations() {
    return <List<String>>[[..._unitActivations], [..._activations]];
  }
  @override
  List<List<double>> getBiases() {
    return <List<double>>[[..._unitBiases], [..._biases]];
  }
  @override
  List<List<double>> getWeights() {
    return <List<double>>[[..._unitWeights], [..._weights]];
  }


  @override
  Vector forwardRetVector(List<double> inputData) {
    // TODO: implement forwardRetVector
    throw UnimplementedError();
  }

  @override
  Vector forwardRetVectorFromVector(Vector inputData) {
    // TODO: implement forwardRetVectorFromVector
    throw UnimplementedError();
  }

  @override
  int getNetworkVersion() {
    return 2;
  }
}
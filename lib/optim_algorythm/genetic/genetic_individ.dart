import 'dart:math';
import 'package:json_annotation/json_annotation.dart';
import 'package:d2_ai_v2/dart_nural/linear_network.dart';


part 'genetic_individ.g.dart';

@JsonSerializable()
class GeneticIndivid {
  /// Веса нейронной сети
  List<double>? weights;

  /// Смещения
  List<double>? biases;

  /// Активационные функции слоёв
  List<String>? activations;

  /// Приспособленность
  double fitness;

  /// История приспособленностей
  List<double> fitnessHistory;

  /// Нужно ли пересчитывать приспособленность
  bool needCalculate;

  /// Инициализирована ли закреплённая за индивидом нейронка
  bool nnInited;

  @JsonKey(ignore: true)
  SimpleLinearNeuralNetwork? nn;

  final int input;
  final int output;
  final int hidden;
  final int layers;

  final random = Random();

  GeneticIndivid({
    required this.input,
    required this.output,
    required this.hidden,
    required this.layers,
    this.fitness = 0,
    this.weights,
    this.biases,
    this.needCalculate = true,
    this.nnInited = false,
    this.activations,
    required this.fitnessHistory,
  }) {
    // Создание нейронки
    final newNN = SimpleLinearNeuralNetwork(
      input: input,
      output: output,
      hidden: hidden,
      layers: layers,
      startWeights: weights,
      startActivations: activations,
      startBiases: biases,
    );
    weights = newNN.weights;
    biases = newNN.biases;
    activations = newNN.layerActivations;
    nn = newNN;
  }

  factory GeneticIndivid.fromJson(Map<String, dynamic> json) => _$GeneticIndividFromJson(json);
  Map<String, dynamic> toJson() => _$GeneticIndividToJson(this);

  GeneticIndivid copyWith({
    weights,
    biases,
    activations,
    fitness,
    input,
    output,
    hidden,
    layers,
    nnInited,
    needCalculate,
    fitnessHistory,
  }) {
    return GeneticIndivid(
      input: input ?? this.input,
      output: output ?? this.output,
      hidden: hidden ?? this.hidden,
      layers: layers ?? this.layers,
      weights: weights ?? this.weights,
      biases: biases ?? this.biases,
      activations: activations ?? this.activations,
      nnInited: nnInited ?? this.nnInited,
      needCalculate: needCalculate ?? this.needCalculate,
        fitnessHistory: fitnessHistory ?? this.fitnessHistory,
    );
  }

  void mutate() {
    // todo Пока тупо выбираем случайные веса
    final maxParamsCount =
        input * hidden + hidden * hidden * layers + hidden * output;
    final weightIndexes = List.generate(
        maxParamsCount ~/ 50, (index) => random.nextInt(maxParamsCount - 1));

    final maxBiasParamsCount =
        hidden * layers + output;
    final biasWeightIndexes = List.generate(
        maxBiasParamsCount ~/ 5, (index) => random.nextInt(maxBiasParamsCount - 1));

    for (var ind in weightIndexes) {
      final newRandomValue = random.nextInt(100);
      if (newRandomValue >= 0 && newRandomValue < 25) {
        weights![ind] = weights![ind] > 0.5 ? 0.0 : 1.0;
      } else if (newRandomValue >= 25 && newRandomValue < 50) {
        weights![ind] = weights![ind] < 0.5 ? 1.0 : 1.0;
      } else if (newRandomValue >= 50 && newRandomValue < 75) {
        weights![ind] = weights![ind] += random.nextDouble()*20.0-10.0;
      } else {
        weights![ind] = weights![ind] -= random.nextDouble()*20.0-10.0;
      }
    }

    // Мутации активационной функции
    if (random.nextInt(100) > 50) {
      final randomLayerIndex = random.nextInt(layers-2);
      final randomVal = random.nextInt(100);
      if (randomVal >= 0 && randomVal < 33) {
        activations![randomLayerIndex] = 'sigmoid';
      } else if (randomVal >= 33 && randomVal < 66) {
        activations![randomLayerIndex] = 'softmax';
      } else if (randomVal >= 66) {
        activations![randomLayerIndex] = 'relu';
      }
    }

    for (var ind in biasWeightIndexes) {

      if (ind >= biases!.length) {
        print('$ind >= ${biases!.length}');
        throw Exception();
      }

      final newRandomValue = random.nextInt(100);
      if (newRandomValue >= 0 && newRandomValue < 25) {
        biases![ind] = biases![ind] > 0.5 ? 0.0 : 1.0;
      } else if (newRandomValue >= 25 && newRandomValue < 50) {
        biases![ind] = biases![ind] < 0.5 ? 1.0 : 1.0;
      } else if (newRandomValue >= 50 && newRandomValue < 75) {
        biases![ind] = biases![ind] += random.nextDouble();
      } else {
        biases![ind] = biases![ind] -= random.nextDouble();
      }
    }

    final newNN = SimpleLinearNeuralNetwork(
      input: input,
      output: output,
      hidden: hidden,
      layers: layers,
      startWeights: weights,
      startActivations: activations,
      startBiases: biases,
    );
    weights = newNN.weights;
    biases = newNN.biases;
    nn = newNN;

    needCalculate = true;
  }

  GeneticIndivid cross(GeneticIndivid target) {
    final maxParamsCount =
        input * hidden + hidden * hidden * layers + hidden * output;
    final maxBiasesParamsCount = hidden * layers + output;

    final weightIndexes = List.generate(
        maxParamsCount ~/ 50, (index) => random.nextInt(maxParamsCount - 1));
    final biasesWeightIndexes = List.generate(maxBiasesParamsCount ~/ 5,
        (index) => random.nextInt(maxBiasesParamsCount - 1));

    final targetHasHighestFitness = target.fitness > fitness;
    final fitnessesEquals = target.fitness == fitness;

    // Вероятность выбрать ген таргета
    final targetGenProp = targetHasHighestFitness
        ? 75
        : fitnessesEquals
            ? 50
            : 25;

    final newWeightsList =
        List.generate(weights!.length, (index) => weights![index]);
    final newBiasesList =
        List.generate(biases!.length, (index) => biases![index]);
    final newActivationsList =
      List.generate(activations!.length, (index) => activations![index]);
    // Новый индивид наследует с вероятность 25% ген менее приспособленного
    for (var ind in weightIndexes) {
      if (random.nextInt(100) > targetGenProp) {
        newWeightsList[ind] = target.weights![ind];
      }
    }
    for (var ind in biasesWeightIndexes) {
      if (random.nextInt(100) > targetGenProp) {
        newBiasesList[ind] = target.biases![ind];
      }
    }
    for (var i=0; i<activations!.length; i++) {
      if (random.nextInt(100) > targetGenProp) {
        newActivationsList[i] = target.activations![i];
      }
    }

    return GeneticIndivid(
      input: input,
      output: output,
      hidden: hidden,
      layers: layers,
      weights: newWeightsList,
      biases: newBiasesList,
      activations: newActivationsList,
      needCalculate: true,
      fitness: 0.0,
      fitnessHistory: [],
    );
  }
}

/// Склонность мутаций того или иного индвивида
class IndividGenomeConfig {

}
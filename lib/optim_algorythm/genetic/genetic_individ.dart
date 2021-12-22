import 'dart:math';

import 'package:d2_ai_v2/dart_nural/linear_network.dart';

class GeneticIndivid {
  /// Веса нейронной сети
  List<double>? weights;

  /// Смещения
  List<double>? biases;

  /// Активационные функции слоёв
  List<String>? activations;

  /// Приспособленность
  double fitness;

  /// Нужно ли пересчитывать приспособленность
  bool needCalculate;

  /// Инициализирована ли закреплённая за индивидом нейронка
  bool nnInited;

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
    nn = newNN;
  }

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
        weights![ind] = weights![ind] += random.nextDouble();
      } else {
        weights![ind] = weights![ind] -= random.nextDouble();
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

    return GeneticIndivid(
      input: input,
      output: output,
      hidden: hidden,
      layers: layers,
      weights: newWeightsList,
      biases: newBiasesList,
      activations: activations,
      needCalculate: true,
    );
  }
}

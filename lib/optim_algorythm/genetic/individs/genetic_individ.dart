import 'dart:math';
import 'package:collection/src/iterable_extensions.dart';
import 'package:d2_ai_v2/dart_nural/networks/linear_network_v2.dart';
import 'package:d2_ai_v2/dart_nural/networks/linear_network_v3.dart';
import 'package:d2_ai_v2/dart_nural/neural_base.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../base.dart';
import '../../individual_base.dart';

part 'genetic_individ.g.dart';

const double mutateValue = 20.0;

@JsonSerializable()
class GeneticIndivid implements IndividualBase {
  /// Веса нейронной сети
  List<double>? weights;

  /// Смещения
  List<double>? biases;

  /// Активационные функции слоёв
  List<String>? activations;

  /// Веса нейронной сети юнитов
  List<double>? unitWeights;

  /// Смещения юнитов
  List<double>? unitBiases;

  /// Активационные функции слоёв юнитов
  List<String>? unitActivations;

  /// Приспособленность
  double fitness;

  /// История приспособленностей
  List<double> fitnessHistory;

  /// Нужно ли пересчитывать приспособленность
  bool needCalculate;

  @JsonKey(ignore: true)
  GameNeuralNetworkBase? nn;
  @JsonKey(ignore: true)
  GameNeuralNetworkBase? unitNn;

  final int input;
  final int output;
  final List<int> unitLayers;
  final List<int> layers;

  final int cellsCount;
  final int unitVectorLength;

  final bool initFrom;

  final random = Random();

  final int networkVersion;

  GeneticIndivid({
    required this.input,
    required this.output,
    required this.layers,
    required this.unitLayers,
    required this.cellsCount,
    required this.unitVectorLength,
    required this.initFrom,
    this.fitness = 0,
    this.weights,
    this.biases,
    this.activations,
    this.unitWeights,
    this.unitBiases,
    this.unitActivations,
    this.needCalculate = true,
    required this.fitnessHistory,
    this.networkVersion = 2, //todo
  }) {
    GameNeuralNetworkBase newNn;

    if (initFrom) {
      assert(weights != null);
      assert(biases != null);
      assert(activations != null);
      assert(unitWeights != null);
      assert(unitBiases != null);
      assert(unitActivations != null);
      if (networkVersion == 3) {
        newNn = LinearNeuralNetworkV3(
            input: input,
            output: output,
            layers: layers,
            unitLayers: unitLayers,
            initFrom: true,
            unitVectorLength: unitVectorLength,
            startWeights: weights,
            startBiases: biases,
            startActivations: activations,
            unitStartWeights: unitWeights,
            unitStartBiases: unitBiases,
            unitStartActivations: unitActivations);
      } else if (networkVersion == 2) {
        newNn = LinearNeuralNetworkV2(
            input: input,
            output: output,
            layers: layers,
            unitLayers: unitLayers,
            initFrom: true,
            unitVectorLength: unitVectorLength,
            startWeights: weights,
            startBiases: biases,
            startActivations: activations,
            unitStartWeights: unitWeights,
            unitStartBiases: unitBiases,
            unitStartActivations: unitActivations);
      } else {
        throw Exception();
      }

    } else {
      if (networkVersion == 3) {
        newNn = LinearNeuralNetworkV3(
            input: input,
            output: output,
            layers: layers,
            unitLayers: unitLayers,
            initFrom: false,
            unitVectorLength: unitVectorLength,
            startWeights: null,
            startBiases: null,
            startActivations: null,
            unitStartWeights: null,
            unitStartBiases: null,
            unitStartActivations: null);
      } else if (networkVersion == 2) {
        newNn = LinearNeuralNetworkV2(
            input: input,
            output: output,
            layers: layers,
            unitLayers: unitLayers,
            initFrom: false,
            unitVectorLength: unitVectorLength,
            startWeights: null,
            startBiases: null,
            startActivations: null,
            unitStartWeights: null,
            unitStartBiases: null,
            unitStartActivations: null);
      } else {
        throw Exception();
      }

    }

    unitWeights = newNn.getWeights()[0];
    unitBiases = newNn.getBiases()[0];
    unitActivations = newNn.getActivations()[0];

    weights = newNn.getWeights()[1];
    biases = newNn.getBiases()[1];
    activations = newNn.getActivations()[1];

    nn = newNn;
  }

  factory GeneticIndivid.fromJson(Map<String, dynamic> json) =>
      _$GeneticIndividFromJson(json);
  Map<String, dynamic> toJson() => _$GeneticIndividToJson(this);

  @override
  GeneticIndivid copyWith({
    input,
    output,
    layers,
    unitLayers,
    cellsCount,
    unitVectorLength,
    initFrom,
    fitnessHistory,
    weights,
    biases,
    activations,
    unitActivations,
    unitBiases,
    unitWeights,
    needCalculate,
  }) {
    return GeneticIndivid(
      input: input ?? this.input,
      output: output ?? this.output,
      layers: layers ?? this.layers,
      unitLayers: unitLayers ?? this.unitLayers,
      cellsCount: cellsCount ?? this.cellsCount,
      unitVectorLength: unitVectorLength ?? this.unitVectorLength,
      initFrom: initFrom ?? this.initFrom,
      fitnessHistory: fitnessHistory ?? this.fitnessHistory,
      weights: weights ?? this.weights,
      biases: biases ?? this.biases,
      activations: activations ?? this.activations,
      unitActivations: unitActivations ?? this.unitActivations,
      unitBiases: unitBiases ?? this.unitBiases,
      unitWeights: unitWeights ?? this.unitWeights,
      needCalculate: needCalculate ?? this.needCalculate,
    );
  }

  bool mutate() {
    final maxUnitNnParamsCount = input * unitLayers.first +
        unitLayers.sum +
        unitLayers.last * unitLayers.last;
    final unitWeightIndexes = List.generate(maxUnitNnParamsCount ~/ 50,
        (index) => random.nextInt(maxUnitNnParamsCount - 1));
    final maxUnitNnBiasesParamsCount = unitLayers.sum + unitLayers.last;
    final unitBiasesWeightIndexes = List.generate(
        maxUnitNnBiasesParamsCount ~/ 5,
        (index) => random.nextInt(maxUnitNnBiasesParamsCount - 1));
    for (var ind in unitWeightIndexes) {
      final newRandomValue = random.nextInt(100);
      if (newRandomValue >= 0 && newRandomValue < 25) {
        unitWeights![ind] = unitWeights![ind] > 0.5 ? 0.0 : 1.0;
      } else if (newRandomValue >= 25 && newRandomValue < 50) {
        unitWeights![ind] = unitWeights![ind] < 0.5 ? 1.0 : 1.0;
      } else if (newRandomValue >= 50 && newRandomValue < 75) {
        unitWeights![ind] =
            unitWeights![ind] += random.nextDouble() * mutateValue - mutateValue/2;
      } else {
        unitWeights![ind] =
            unitWeights![ind] -= random.nextDouble() * mutateValue - mutateValue/2;
      }
    }
    for (var ind in unitBiasesWeightIndexes) {
      final newRandomValue = random.nextInt(100);
      if (newRandomValue >= 0 && newRandomValue < 25) {
        unitBiases![ind] = unitBiases![ind] > 0.5 ? 0.0 : 1.0;
      } else if (newRandomValue >= 25 && newRandomValue < 50) {
        unitBiases![ind] = unitBiases![ind] < 0.5 ? 1.0 : 1.0;
      } else if (newRandomValue >= 50 && newRandomValue < 75) {
        unitBiases![ind] = unitBiases![ind] += random.nextDouble() * mutateValue - mutateValue/2;
      } else {
        unitBiases![ind] = unitBiases![ind] -= random.nextDouble() * mutateValue - mutateValue/2;
      }
    }
    if (random.nextInt(100) > 50) {
      final randomLayerIndex = random.nextInt(unitLayers.length-1);
      final randomVal = random.nextInt(100);
      if (randomVal >= 0 && randomVal < 33) {
        unitActivations![randomLayerIndex] = 'sigmoid';
      } else if (randomVal >= 33 && randomVal < 66) {
        unitActivations![randomLayerIndex] = 'softmax';
      } else if (randomVal >= 66) {
        unitActivations![randomLayerIndex] = 'relu';
      }
    }

    final maxNnParamsCount = unitLayers.first * layers.first +
        layers.sum +
        layers.last * output;
    final weightIndexes = List.generate(maxNnParamsCount ~/ 50,
        (index) => random.nextInt(maxNnParamsCount - 1));
    final maxNnBiasesParamsCount = layers.sum + output;
    final biasesWeightIndexes = List.generate(maxNnBiasesParamsCount ~/ 5,
        (index) => random.nextInt(maxNnBiasesParamsCount - 1));
    for (var ind in weightIndexes) {
      final newRandomValue = random.nextInt(100);
      if (newRandomValue >= 0 && newRandomValue < 25) {
        weights![ind] = weights![ind] > 0.5 ? 0.0 : 1.0;
      } else if (newRandomValue >= 25 && newRandomValue < 50) {
        weights![ind] = weights![ind] < 0.5 ? 1.0 : 1.0;
      } else if (newRandomValue >= 50 && newRandomValue < 75) {
        weights![ind] = weights![ind] += random.nextDouble() * 2.0 - 1.0;
      } else {
        weights![ind] = weights![ind] -= random.nextDouble() * 2.0 - 1.0;
      }
    }
    for (var ind in biasesWeightIndexes) {
      final newRandomValue = random.nextInt(100);
      if (newRandomValue >= 0 && newRandomValue < 25) {
        biases![ind] = biases![ind] > 0.5 ? 0.0 : 1.0;
      } else if (newRandomValue >= 25 && newRandomValue < 50) {
        biases![ind] = biases![ind] < 0.5 ? 1.0 : 1.0;
      } else if (newRandomValue >= 50 && newRandomValue < 75) {
        biases![ind] = biases![ind] += random.nextDouble() * 2.0 - 1.0;
      } else {
        biases![ind] = biases![ind] -= random.nextDouble() * 2.0 - 1.0;
      }
    }
    if (random.nextInt(100) > 50) {
      final randomLayerIndex = random.nextInt(layers.length-1);
      final randomVal = random.nextInt(100);
      if (randomVal >= 0 && randomVal < 33) {
        activations![randomLayerIndex] = 'sigmoid';
      } else if (randomVal >= 33 && randomVal < 66) {
        activations![randomLayerIndex] = 'softmax';
      } else if (randomVal >= 66) {
        activations![randomLayerIndex] = 'relu';
      }
    }
    GameNeuralNetworkBase newNN;
    if (networkVersion == 2) {
      newNN = LinearNeuralNetworkV2(
        input: input,
        output: output,
        layers: layers,
        unitLayers: unitLayers,
        initFrom: true,
        cellsCount: cellsCount,
        unitVectorLength: unitVectorLength,
        startWeights: weights,
        startBiases: biases,
        startActivations: activations,
        unitStartWeights: unitWeights,
        unitStartBiases: unitBiases,
        unitStartActivations: unitActivations,
      );
    } else if (networkVersion == 3) {
      newNN = LinearNeuralNetworkV3(
        input: input,
        output: output,
        layers: layers,
        unitLayers: unitLayers,
        initFrom: true,
        cellsCount: cellsCount,
        unitVectorLength: unitVectorLength,
        startWeights: weights,
        startBiases: biases,
        startActivations: activations,
        unitStartWeights: unitWeights,
        unitStartBiases: unitBiases,
        unitStartActivations: unitActivations,
      );
    } else {
      throw Exception();
    }


    unitWeights = newNN.getWeights()[0];
    unitBiases = newNN.getBiases()[0];
    unitActivations = newNN.getActivations()[0];

    weights = newNN.getWeights()[1];
    biases = newNN.getBiases()[1];
    activations = newNN.getActivations()[1];

    nn = newNN;

    needCalculate = true;
    return true;
  }

  @override
  IndividualBase cross(IndividualBase target) {
    // todo Старался не нарушать принцип разделения интерфейсов,
    // в итоге получилась такая фигня с приведением типов
    target = target as GeneticIndivid;

    final maxUnitNnParamsCount = input * unitLayers.first +
        unitLayers.sum +
        unitLayers.last * unitLayers.last; // todo
    final unitWeightIndexes = List.generate(maxUnitNnParamsCount ~/ 50,
        (index) => random.nextInt(maxUnitNnParamsCount - 1));
    final maxUnitNnBiasesParamsCount = unitLayers.sum + unitLayers.last;
    final unitBiasesWeightIndexes = List.generate(
        maxUnitNnBiasesParamsCount ~/ 5,
        (index) => random.nextInt(maxUnitNnBiasesParamsCount - 1));

    final maxNnParamsCount = unitLayers.last * layers.first +
        layers.sum +
        layers.last * output;
    final weightIndexes = List.generate(maxNnParamsCount ~/ 50,
        (index) => random.nextInt(maxNnParamsCount - 1));
    final maxNnBiasesParamsCount = layers.sum + output;
    final biasesWeightIndexes = List.generate(maxNnBiasesParamsCount ~/ 5,
        (index) => random.nextInt(maxNnBiasesParamsCount - 1));

    final targetHasHighestFitness = target.getFitness() > fitness;
    final fitnessesEquals = target.getFitness() == fitness;

    // Вероятность выбрать ген таргета
    final targetGenProp = targetHasHighestFitness
        ? 55
        : fitnessesEquals
            ? 50
            : 45;

    int unitNeuralIndex = 0;
    int neuralIndex = 1;

    final newUnitWeightsList =
        List.generate(unitWeights!.length, (index) => unitWeights![index]);
    final newUnitBiasesList =
        List.generate(unitBiases!.length, (index) => unitBiases![index]);
    final newUnitActivationsList = List.generate(
        unitActivations!.length, (index) => unitActivations![index]);
    // Новый индивид наследует с вероятность 25% ген менее приспособленного
    for (var ind in unitWeightIndexes) {
      if (random.nextInt(100) > targetGenProp) {
        newUnitWeightsList[ind] = target.getWeights()[unitNeuralIndex][ind];
      }
    }
    for (var ind in unitBiasesWeightIndexes) {
      if (random.nextInt(100) > targetGenProp) {
        newUnitBiasesList[ind] = target.getBiases()[unitNeuralIndex][ind];
      }
    }
    for (var i = 0; i < unitActivations!.length; i++) {
      if (random.nextInt(100) > targetGenProp) {
        newUnitActivationsList[i] = target.getActivations()[unitNeuralIndex][i];
      }
    }

    final newWeightsList =
        List.generate(weights!.length, (index) => weights![index]);
    final newBiasesList =
        List.generate(biases!.length, (index) => biases![index]);
    final newActivationsList =
        List.generate(activations!.length, (index) => activations![index]);
    // Новый индивид наследует с вероятность 25% ген менее приспособленного
    for (var ind in weightIndexes) {
      if (random.nextInt(100) > targetGenProp) {
        newWeightsList[ind] = target.getWeights()[neuralIndex][ind];
      }
    }
    for (var ind in biasesWeightIndexes) {
      if (random.nextInt(100) > targetGenProp) {
        newBiasesList[ind] = target.getBiases()[neuralIndex][ind];
      }
    }
    for (var i = 0; i < activations!.length; i++) {
      if (random.nextInt(100) > targetGenProp) {
        newActivationsList[i] = target.getActivations()[neuralIndex][i];
      }
    }

    assert(networkVersion == target.getAlgorithmVersion());

    return GeneticIndivid(
      networkVersion: networkVersion,
      input: input,
      output: output,
      layers: layers,
      unitLayers: unitLayers,
      cellsCount: cellsCount,
      unitVectorLength: unitVectorLength,
      initFrom: true,
      fitnessHistory: [],
      fitness: 0.0,
      unitWeights: newUnitWeightsList,
      unitBiases: newUnitBiasesList,
      unitActivations: newUnitActivationsList,
      weights: newWeightsList,
      biases: newBiasesList,
      activations: newActivationsList,
      needCalculate: true,
    );

    /*final newWeightsList =
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
    }*/

    /*final maxParamsCount =
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
    }*/

    /*return GeneticIndivid(
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
    );*/
    //return target.copyWith(); //todo
  }

  @override
  double getFitness() {
    return fitness;
  }

  @override
  List<double> getFitnessHistory() {
    return fitnessHistory;
  }

  @override
  void setFitness(double fitness) {
    this.fitness = fitness;
  }

  @override
  AiAlgorithm getAlgorithm() {
    return nn!;
  }

  @override
  List<List<String>> getActivations() {
    return <List<String>>[
      unitActivations!,
      activations!,
    ];
  }

  @override
  List<List<double>> getBiases() {
    return <List<double>>[
      unitBiases!,
      biases!,
    ];
  }

  @override
  List<List<double>> getWeights() {
    return <List<double>>[
      unitWeights!,
      weights!,
    ];
  }

  @override
  int getAlgorithmVersion() {
    return networkVersion;
  }

  @override
  IndividualBase deepCopy() {
    // TODO: implement deepCopy
    throw UnimplementedError();
  }
}

/// Склонность мутаций того или иного индвивида
class IndividGenomeConfig {}

import 'dart:math';

import 'package:collection/src/iterable_extensions.dart';
import 'package:d2_ai_v2/utils/activations_mixin.dart';

import '../node_base.dart';
import 'package:json_annotation/json_annotation.dart';

part 'node_v1.g.dart';

@JsonSerializable()
class NodeV1 with MathMixin implements TreeNodeBase {
  int id;
  String activation;
  double bias;
  late Activation _activationFunc;

  bool memorable;
  late List<double> lastOutputs;
  int memorableDepth = 1;

  static List<String> activations = [
    'none',
    'sigmoid',
    'relu',
    'th',
    'elu',
    'lrelu',
  ];

  NodeV1({
    required this.id,
    required this.activation,
    required this.bias,
    required this.memorable,
    required this.memorableDepth,
  }) {
    lastOutputs = [];
    _activationFunc = activationFunctionFromString(activation);
  }

  factory NodeV1.fromJson(Map<String, dynamic> json) => _$NodeV1FromJson(json);

  @override
  Map<String, dynamic> toJson() => _$NodeV1ToJson(this);

  factory NodeV1.random(int id, Random random) {
    return NodeV1(
      activation: getRandomElement<String>(
          ['sigmoid', 'relu', 'th', 'elu', 'lrelu'], random),
      id: id,
      bias: randomRange(-1.0, 1.0, random),
      memorable: false,
      memorableDepth: 1,
    );
  }

  factory NodeV1.randomWithoutActivation(int id, Random random) {
    return NodeV1(
      memorable: false,
      memorableDepth: 1,
      activation: 'none',
      id: id,
      bias: randomRange(-1.0, 1.0, random),
    );
  }

  @override
  double calculate(List<double> input) {
    if (input.isEmpty) {
      return bias;
    }

    var vectorSum = input.sum;
    vectorSum += bias;
    final currentVector = _activationFunc([vectorSum]);
    final output = currentVector[0];

    if (memorable) {
      assert(false);
      assert(memorableDepth > 0);

      if (lastOutputs.length < memorableDepth) {
        lastOutputs.add(output);
        return output;
      }

      if (lastOutputs.length == memorableDepth) {

        var newVectorSum = input.sum;
        var memorySum = lastOutputs.sum;
        var inputSumWithMemory = newVectorSum + memorySum;
        inputSumWithMemory += bias;
        final outputVectorWithMem = _activationFunc([inputSumWithMemory]);
        final outputWithMem = outputVectorWithMem[0];
        lastOutputs.clear();
        return outputWithMem;
      }

      throw Exception();


    } else {
      return output;
    }
  }

  @override
  String getActivation() {
    return activation;
  }

  @override
  int getId() {
    return id;
  }

  @override
  void setActivation(String activation) {
    this.activation = activation;
    _activationFunc = activationFunctionFromString(activation);
  }

  @override
  NodeV1 deepCopy() {
    return NodeV1(
        id: id,
        activation: activation,
        bias: bias,
        memorableDepth: memorableDepth,
        memorable: memorable);
  }

  @override
  void mutate() {
    callRandomFunc([
      _mutateBias,
      _mutateActivation,
      //_mutateMemorable, // todo Работает странно
      //if (memorable) _mutateMemorableDepth,  // todo Работает странно
    ], random);
  }

  void _mutateBias() {
    callRandomFunc([
      () => bias += random.nextDouble(),
      () => bias -= random.nextDouble(),
      () => bias = 1.0,
      () => bias = 0.0,
    ], random);
  }

  void _mutateActivation() {
    callRandomFunc([
      () => setActivation('sigmoid'),
      () => setActivation('relu'),
      () => setActivation('elu'),
      () => setActivation('lrelu'),
      () => setActivation('th'),
    ], random);
  }

  void _mutateMemorable() {
    callRandomFunc([
      () => memorable = !memorable,
    ], random);
  }

  void _mutateMemorableDepth() {
    callRandomFunc([
          () => memorableDepth++,
          if (memorableDepth > 1) () => memorableDepth--,
    ], random);
  }
}

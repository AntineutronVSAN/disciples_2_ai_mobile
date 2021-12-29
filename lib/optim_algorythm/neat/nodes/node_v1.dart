

import 'package:collection/src/iterable_extensions.dart';
import 'package:d2_ai_v2/utils/activations_mixin.dart';

import '../node_base.dart';

class NodeV1 with MathMixin implements TreeNodeBase {

  int id;
  String activation;
  late Activation _activationFunc;

  /// Дефолтное значение, которые выдаёт узел, если в него нет входов
  final double defaultValue;

  NodeV1({
    required this.id,
    required this.activation,
    required this.defaultValue,
  }) {
    _activationFunc = activationFunctionFromString(activation);
  }

  factory NodeV1.random(int id) {
    return NodeV1(activation: getRandomActivation(), id: id, defaultValue: getRandomValue());
  }
  factory NodeV1.randomWithoutActivation(int id) {
    return NodeV1(activation: 'none', id: id, defaultValue: getRandomValue());
  }

  @override
  double calculate(List<double> input) {
    if (input.isEmpty) {
      return defaultValue;
    }

    final currentVector = _activationFunc([input.sum]);
    return currentVector[0];

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
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }

}
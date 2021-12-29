

import 'dart:math';

import 'package:d2_ai_v2/utils/activations_mixin.dart';

import '../edge_base.dart';

class EdgeV1 with MathMixin implements TreeEdgeBase {

  int id;
  double weigth;

  EdgeV1({required this.id, required this.weigth});

  factory EdgeV1.random(int id) {
    return EdgeV1(id: id, weigth: Random().nextDouble());
  }

  @override
  double calculate(double input) {
    return input*weigth;
  }

  @override
  int getId() {
    return id;
  }

  @override
  double getWeight() {
    return weigth;
  }

  @override
  void setWeight(double val) {
    weigth = val;
  }

  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }

  @override
  String toString() {
    return 'Edge. ID = $id';
  }
}
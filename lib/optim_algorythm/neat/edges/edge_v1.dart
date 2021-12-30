

import 'dart:math';

import 'package:d2_ai_v2/utils/activations_mixin.dart';

import '../edge_base.dart';
import 'package:json_annotation/json_annotation.dart';

part 'edge_v1.g.dart';

@JsonSerializable()
class EdgeV1 with MathMixin implements TreeEdgeBase {

  int id;
  double weight;

  EdgeV1({required this.id, required this.weight});

  factory EdgeV1.fromJson(Map<String, dynamic> json) =>
      _$EdgeV1FromJson(json);
  @override
  Map<String, dynamic> toJson() => _$EdgeV1ToJson(this);

  factory EdgeV1.random(int id) {
    return EdgeV1(id: id, weight: Random().nextDouble());
  }

  @override
  double calculate(double input) {
    return input*weight;
  }

  @override
  int getId() {
    return id;
  }

  @override
  double getWeight() {
    return weight;
  }

  @override
  void setWeight(double val) {
    weight = val;
  }

  @override
  String toString() {
    return 'Edge. ID = $id';
  }

  @override
  EdgeV1 deepCopy() {
    return EdgeV1(id: id, weight: weight);
  }
}
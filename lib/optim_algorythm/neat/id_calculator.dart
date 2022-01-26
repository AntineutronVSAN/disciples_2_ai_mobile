import 'package:json_annotation/json_annotation.dart';

part 'id_calculator.g.dart';


@JsonSerializable()
class IdCalculator {
  int currentId;

  IdCalculator({this.currentId = -1});

  int getNextId() {
    currentId++;
    return currentId;
  }

  int fromID(int id) {
    assert(id > currentId);
    currentId = id;
    return id;
  }

  IdCalculator deepCopy() {
    return IdCalculator(currentId: currentId);
  }

  factory IdCalculator.fromJson(Map<String, dynamic> json) =>
      _$IdCalculatorFromJson(json);
  Map<String, dynamic> toJson() => _$IdCalculatorToJson(this);

}
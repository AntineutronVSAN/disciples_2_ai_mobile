import 'package:d2_ai_v2/models/unit.dart';

class AttackContext {
  int current;
  int target;
  List<Unit> units;
  bool topFrontLineEmpty;
  bool botFrontLineEmpty;
  List<bool> cellHasUnit;
  bool isFirstAttack;

  AttackContext({
    required this.current,
    required this.target,
    required this.units,
    required this.topFrontLineEmpty,
    required this.botFrontLineEmpty,
    required this.cellHasUnit,
    this.isFirstAttack = true,
  });

  AttackContext copyWith({
    current,
    target,
    units,
    topFrontLineEmpty,
    botFrontLineEmpty,
    cellHasUnit,
    isFirstAttack,
  }) {
    return AttackContext(
      current: current ?? this.current,
      target: target ?? this.target,
      units: units ?? this.units,
      topFrontLineEmpty: topFrontLineEmpty ?? this.topFrontLineEmpty,
      botFrontLineEmpty: botFrontLineEmpty ?? this.botFrontLineEmpty,
      cellHasUnit: cellHasUnit ?? this.cellHasUnit,
      isFirstAttack: isFirstAttack ?? this.isFirstAttack,
    );
  }
}
